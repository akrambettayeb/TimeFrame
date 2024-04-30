//
//  AlbumViewController.swift
//  TimeFrame
//
//  Created by Brandon Ling on 3/18/24.
// 
//  Project: TimeFrame
//  EID: bml2426
//  Course: CS371L


import UIKit
import AVFoundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import UserNotifications


class AlbumCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    
    func setupButtonTarget(for indexPath: IndexPath, target: Any?, action: Selector) {
        selectButton.addTarget(target, action: action, for: .touchUpInside)
        selectButton.tag = indexPath.item
    }
}


class AlbumViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var collectionView: UICollectionView!
    var albumName: String?
    let reuseIdentifier = "PhotoCell"
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var hideSelectButtons = true
    
    // Stores images the user selects to use to create the TimeFrame
    var selectedPhotos: [AlbumPhoto] = []
    var overlayView: UIView!
    var currentCameraPosition: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        self.createMenu()
        self.title = albumName
        moreButton.isHidden = false
        doneButton.isHidden = true
        cancelButton.isHidden = true
        hideSelectButtons = true
        self.clearSelections()
        collectionView.dataSource = self
        collectionView.delegate = self
        imagePicker.delegate = self
        requestNotificationPermission()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        moreButton.isHidden = !hideSelectButtons
        doneButton.isHidden = hideSelectButtons
        cancelButton.isHidden = hideSelectButtons
        if hideSelectButtons {
            self.clearSelections()
        }
        collectionView.reloadData()
    }
    
    // Defines layout for the collection view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let collectionWidth = collectionView.bounds.width
        let cellSize = (collectionWidth - 11) / 3
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
    }

    // Sets up dropdown items for navigation item in top-right corner
    func createMenu() {
        title = "Album"
        // Add photo action
        let addPhotoMenuItem = UIAction(title: "Add Photo", image: UIImage(systemName: "plus")) { _ in
            self.showCamera() //TODO: error with empty albums
        }
        
        // Create TimeFrame action
        let createTimeframeMenuItem = UIAction(title: "Create TimeFrame", image: UIImage(systemName: "plus")) { _ in
            self.hideSelectButtons = false
            self.collectionView.reloadData()
            self.moreButton.isHidden = true
            self.doneButton.isHidden = false
            self.cancelButton.isHidden = false
        }
        
        // Rename album action
//        let renameAlbumMenuItem = UIAction(title: "Rename Album", 
//            image: UIImage(systemName: "pencil")) { _ in
//            self.renameAlbum()
//        }
        
        // Delete album action
        let deleteAlbumMenuItem = UIAction(title: "Delete Album", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.deleteAlbum()
        }
            
        let menu = UIMenu(title: "Album Menu", children: [addPhotoMenuItem, createTimeframeMenuItem, deleteAlbumMenuItem])
        moreButton.menu = menu
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allAlbums[albumName!]!.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AlbumCell
        
        // Configure cell image
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.clipsToBounds = true
        cell.imageView.image = allAlbums[albumName!]![indexPath.row].image
        
        // Configure cell button
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .clear
        cell.selectButton.configuration = config
        cell.selectButton.setImage(UIImage(systemName: "circle"), for: .normal)
        cell.selectButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .selected)
        cell.selectButton.tintColor = UIColor(named: "TabBarPurple")
        cell.selectButton.isHidden = hideSelectButtons
        cell.setupButtonTarget(for: indexPath, target: self, action: #selector(buttonTapped(_:)))
        cell.selectButton.isSelected = allAlbums[albumName!]![indexPath.row].buttonSelected
        
        return cell
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first(where: { $0.item == sender.tag}) else {
            return
        }
        let isSelected = !(allAlbums[albumName!]![indexPath.row].buttonSelected)
        collectionView.cellForItem(at: indexPath)!.isSelected = isSelected
        allAlbums[albumName!]![indexPath.row].buttonSelected = isSelected
        collectionView.reloadItems(at: [indexPath])
    }
    
    // Iterates through all cells in the collection view and sets the button state to unselected
    func clearSelections() {
        let numPhotos = allAlbums[albumName!]!.count
        if numPhotos == 0 {
            return
        }
        for index in 0...numPhotos - 1 {
            allAlbums[albumName!]![index].buttonSelected = false
        }
    }
    
    @IBAction func onDoneTapped(_ sender: Any) {
        selectedPhotos = [AlbumPhoto]()
        
        // Adds images from selected cells to the selectedPhotos array
        for indexPath in collectionView.indexPathsForVisibleItems {
            if allAlbums[albumName!]![indexPath.row].buttonSelected {
                let selectedPhoto = allAlbums[albumName!]![indexPath.row]
                selectedPhotos.append(selectedPhoto)
            }
        }
        
        // Checks that multiple photos are selected to create a TimeFrame
        if selectedPhotos.count < 2 {
            selectedPhotos = [AlbumPhoto]()
            let alert = UIAlertController(title: "Not Enough Photos Selected", message: "Please select multiple photos to create a TimeFrame. ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        
        self.performSegue(withIdentifier: "segueToPlaybackSettings", sender: self)
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        moreButton.isHidden = false
        cancelButton.isHidden = true
        doneButton.isHidden = true
        self.clearSelections()
        self.hideSelectButtons = true
        collectionView.reloadData()
    }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            var finalImage = image
            if currentCameraPosition == UIImagePickerController.CameraDevice.front.rawValue {
                // Prevent flipping of front-facing photos.
                finalImage = image.flipHorizontally()!
            }
            self.uploadPhoto(image: finalImage)
            var existingImages = allAlbums[albumName!] ?? []  // Creates array if value is empty
            existingImages.append(AlbumPhoto(finalImage))
            allAlbums[albumName!] = existingImages
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadPhoto(image: UIImage) {
        guard let albumName = albumName,
              let imageData = image.jpegData(compressionQuality: 0.5),
              let userID = Auth.auth().currentUser?.uid else {
            print("Invalid album name, image data, or user not authenticated")
            return
        }
        
        let photoFilename = "\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child("users").child(userID).child("albums").child(albumName).child(photoFilename)
        
        storageRef.putData(imageData, metadata: nil) { [weak self] (metadata, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
            } else {
                storageRef.downloadURL { (url, error) in
                    if let downloadURL = url?.absoluteString {
                        self.saveImageUrlToFirestore(downloadURL: downloadURL, albumName: albumName)
                        // Update streak information after successful upload
                        self.updateStreakInformationForAlbum(albumName: albumName)
                    }
                }
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            }
        }
    }

    func updateStreakInformationForAlbum(albumName: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        let albumRef = db.collection("users").document(userID).collection("albums").document(albumName)
        
        let now = Date()
        let calendar = Calendar.current
        let nextDeadline = calendar.date(byAdding: .day, value: 1, to: now)
        
        albumRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                var currentStreak = document.get("currentStreak") as? Int ?? 0
                let currentDeadline = document.get("currentDeadline") as? Timestamp
                
                if let currentDeadlineDate = currentDeadline?.dateValue(), now <= currentDeadlineDate {
                    // Increment streak if upload is within the deadline
                    currentStreak += 1
                } else {
                    // Reset streak if the deadline has passed
                    currentStreak = 1
                }
                
                // Update Firestore with the new streak and deadline
                albumRef.updateData([
                    "currentStreak": currentStreak,
                    // Use nextDeadline directly since it's not nil
                    "currentDeadline": Timestamp(date: nextDeadline!)
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated with new streak information")
                        // Schedule notification for current streak
                        if currentStreak % 2 == 0 {
                            self?.scheduleStreakNotification(streakDays: currentStreak)
                        }
                        // Schedule immediate notification
                        self?.scheduleImmediateStreakUpdateNotification()
                    }
                }
            } else {
                print("Document does not exist, creating with initial streak data")
                // If the document doesn't exist, create it with initial streak information
                albumRef.setData([
                    "currentStreak": 1,
                    "currentDeadline": Timestamp(date: nextDeadline!)
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written with initial streak information")
                        // Schedule immediate notification for the first upload
                        self?.scheduleImmediateStreakUpdateNotification()
                    }
                }
            }
        }
    }

    func saveImageUrlToFirestore(downloadURL: String, albumName: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let db = Firestore.firestore()
        let timestamp = FieldValue.serverTimestamp()
        
        // Get the current date components
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        
        // Format date to Month/Day/Year
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let formattedDate = dateFormatter.string(from: Date())
        
        // Format month to Month/Year
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"
        let formattedMonth = monthFormatter.string(from: Date())
        
        // Format year to Year
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let formattedYear = yearFormatter.string(from: Date())
        
        let photoData: [String: Any] = [
            "url": downloadURL,
            "uploadDate": timestamp,
            "date": formattedDate,
            "month": formattedMonth,
            "year": formattedYear
        ]
        
        db.collection("users").document(userID).collection("albums").document(albumName).collection("photos").addDocument(data: photoData) { [weak self] (error) in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added successfully")
                self?.collectionView.reloadData()
            }
        }
    }
        
    // Deletes this album from Firestore
    func deleteAlbum() {
        let controller = UIAlertController(
            title: "Delete Album",
            message: "Please confirm that you would like to delete \(albumName!). ",
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {
            _ in
            let userID = Auth.auth().currentUser!.uid
            let userRef = Firestore.firestore().collection("users").document(userID)
            let albumRef = userRef.collection("albums").document(self.albumName!)
            
            albumRef.delete { error in
                if let error = error {
                    print("Error deleting album: \(error.localizedDescription)")
                } else {
                    albumNames = albumNames.filter{$0 != self.albumName}
                    allAlbums.removeValue(forKey: self.albumName!)
                    let successController = UIAlertController(
                        title: "Success",
                        message: "\(self.albumName!) has been deleted!",
                        preferredStyle: .alert
                    )
                    successController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(successController, animated: true)
                }
            }
        }))
        present(controller, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToViewAlbumImage",
        let nextVC = segue.destination as? ViewAlbumImageVC {
            if let indexPaths = collectionView.indexPathsForSelectedItems {
                // Passes the selected image to the next screen to view the image from the album in a new screen
                let imageIndex = indexPaths[0].row
                nextVC.selectedImage = allAlbums[albumName!]![imageIndex].image
                collectionView.deselectItem(at: indexPaths[0], animated: false)
            }
        } else if segue.identifier == "segueToPlaybackSettings",
          let nextVC = segue.destination as? PlaybackSettingsVC {
            // Passes all selected photos (as an array) to the next screen to define settings for the photos to use in the TimeFrame
            nextVC.selectedPhotos = self.selectedPhotos
        }
    }
    
    func scheduleStreakNotification(streakDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = "\(streakDays) day streak 🔥"
        content.body = "You're on a roll! Keep it up!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (2 * 24 * 60 * 60), repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling streak notification: \(error)")
            }
        }
    }

    func scheduleImmediateStreakUpdateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Great job!"
        content.body = "Come back tomorrow to keep it going."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling streak update notification: \(error)")
            }
        }
    }
    
    func showCamera() {
        // Ask for camera permission.
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) {
                    accessGranted in guard accessGranted == true
                    else {return}
                }
            case .authorized:
                break
            default:
                print("Access denied.") //TODO: show some error and segue if access denied
                return
            }
            
            self.imagePicker.sourceType = .camera
            self.currentCameraPosition = self.imagePicker.cameraDevice.rawValue
            self.imagePicker.showsCameraControls = false
            self.imagePicker.allowsEditing = false //TODO: add and delete photos from firebase
            self.imagePicker.cameraCaptureMode = .photo
            self.imagePicker.cameraFlashMode = .off
            let translation = CGAffineTransformMakeTranslation(0.0, 123)
            self.imagePicker.cameraViewTransform = translation
            
            self.overlayView = createOverlayView()
            self.imagePicker.cameraOverlayView = self.overlayView
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func createOverlayView() -> UIView {
        // Create container view for overlay elements.
        let containerView = UIView(frame: UIScreen.main.bounds)
        containerView.backgroundColor = .clear
        
        // Add top and bottom rectangles of overlay.
        let topRect = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 123))
        topRect.backgroundColor = .black
        containerView.addSubview(topRect)
        
        let bottomRect = UIView(frame: CGRect(x: 0, y: 643, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.maxY - 643))
        bottomRect.backgroundColor = .black
        containerView.addSubview(bottomRect)
        
        
        // Add image overlay to camera preview.
        if allAlbums[self.albumName!]!.count > 0 {
            // Only add overlay if existing photo in album.
            let imageOverlay = UIImageView(frame: CGRect(x: 0, y: 123, width: UIScreen.main.bounds.width, height: 643 - 123))
            imageOverlay.image = allAlbums[self.albumName!]!.last?.image
            imageOverlay.contentMode = .scaleAspectFill
            imageOverlay.alpha = 0.4
            containerView.addSubview(imageOverlay)
        }
        
        // Add buttons to overlay.
        let captureButton = UIButton(frame: CGRect(x: 146, y: 643 + 46, width: 100, height: 100))
        let captureConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
        let captureImage = UIImage(systemName: "button.programmable", withConfiguration: captureConfig)
        captureButton.setImage(captureImage, for: .normal)
        captureButton.tintColor = .white
        captureButton.addTarget(self, action: #selector(onCaptureButtonPressed), for: .touchUpInside)
        containerView.addSubview(captureButton)
        
        let flipButton = UIButton(frame: CGRect(x: 325, y: 643 + 71, width: 48, height: 48))
        let flipConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular)
        let flipImage = UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: flipConfig)
        flipButton.setImage(flipImage, for: .normal)
        flipButton.tintColor = .white
        var tintConfig = UIButton.Configuration.tinted()
        tintConfig.cornerStyle = .capsule
        flipButton.configuration = tintConfig
        flipButton.addTarget(self, action: #selector(onFlipButtonPressed), for: .touchUpInside)
        containerView.addSubview(flipButton)
        
        let cancelButton = UIButton(frame: CGRect(x: 8, y: 643 + 78, width: 81, height: 35))
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(onCancelButtonPressed), for: .touchUpInside)
        containerView.addSubview(cancelButton)
        
        return containerView
    }
    
    // Capture photo.
    @objc func onCaptureButtonPressed() {
        self.imagePicker.takePicture()
    }
    
    // Flip the camera.
    @objc func onFlipButtonPressed() {
        if currentCameraPosition == UIImagePickerController.CameraDevice.rear.rawValue {
            // Flip to front camera.
            self.imagePicker.cameraDevice = UIImagePickerController.CameraDevice.front
            currentCameraPosition = self.imagePicker.cameraDevice.rawValue
        } else if currentCameraPosition == UIImagePickerController.CameraDevice.front.rawValue {
            // Flip to rear camera.
            self.imagePicker.cameraDevice = UIImagePickerController.CameraDevice.rear
            currentCameraPosition = self.imagePicker.cameraDevice.rawValue
        }
    }
    
    // Dismiss popover.
    @objc func onCancelButtonPressed() {
        dismiss(animated: true)
    }
}
