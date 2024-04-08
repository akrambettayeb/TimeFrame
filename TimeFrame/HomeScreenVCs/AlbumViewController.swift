//
//  AlbumViewController.swift
//  TimeFrame
//
//  Created by Brandon Ling on 3/18/24.
// 
// Project: TimeFrame
// EID: bml2426
// Course: CS371L


import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class AlbumCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    
    @IBAction func onSelectTapped(_ sender: Any) {
        selectButton.isSelected = !selectButton.isSelected
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
    var selectedPhotos: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        self.createMenu()
        self.title = albumName
        moreButton.isHidden = false
        doneButton.isHidden = true
        cancelButton.isHidden = true
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        moreButton.isHidden = !hideSelectButtons
        doneButton.isHidden = hideSelectButtons
        cancelButton.isHidden = hideSelectButtons
    }
    
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
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
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
        let renameAlbumMenuItem = UIAction(title: "Rename Album", image: UIImage(systemName: "pencil")) { _ in
            self.renameAlbum()
        }
        // Delete album action
        let deleteAlbumMenuItem = UIAction(title: "Delete Album", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.deleteAlbum()
        }
            
        let menu = UIMenu(title: "Album Menu", children: [addPhotoMenuItem, createTimeframeMenuItem, renameAlbumMenuItem, deleteAlbumMenuItem])
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
        cell.imageView.image = allAlbums[albumName!]![indexPath.row]
        
        // Configure cell button
        cell.selectButton.setImage(UIImage(systemName: "circle"), for: .normal)
        cell.selectButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .selected)
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .clear
        cell.selectButton.configuration = config
        cell.selectButton.isHidden = hideSelectButtons
        
        return cell
    }
    
    func hideSelectButtons(_ hidden: Bool) {
        for indexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: indexPath) as? AlbumCell {
                cell.selectButton.isHidden = hidden
            }
        }
    }
    
    func setButtonStates(_ selected: Bool) {
        for indexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: indexPath) as? AlbumCell {
                cell.selectButton.isSelected = selected
            }
        }
    }
    
    @IBAction func onDoneTapped(_ sender: Any) {
        // Adds images from selected cells to the selectedPhotos array
        for indexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: indexPath) as? AlbumCell {
                if cell.selectButton.isSelected {
                    selectedPhotos.append(cell.imageView.image!)
                }
            }
        }
        
        if selectedPhotos.count < 2 {
            selectedPhotos = [UIImage]()
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
        self.setButtonStates(false)
        self.hideSelectButtons = true
        collectionView.reloadData()
    }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.uploadPhoto(image: image)
            var existingImages = allAlbums[albumName!] ?? []  // Creates array if value is empty
            existingImages.append(image)
            allAlbums[albumName!] = existingImages
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadPhoto(image: UIImage) {
        guard let albumName = albumName,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Invalid album name or image data")
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let photoFilename = "\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child("users").child(userID).child("albums").child(albumName).child(photoFilename)
        
        storageRef.putData(imageData, metadata: nil) { [weak self] (metadata, error) in
            if let error = error {
                print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
            } else {
                storageRef.downloadURL { (url, error) in
                    if let downloadURL = url?.absoluteString {
                        // Save download URL to Firestore
                        self?.saveImageUrlToFirestore(downloadURL: downloadURL, albumName: albumName)
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
        monthFormatter.dateFormat = "MM/yyyy"
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
        
    func renameAlbum() {
        // Handle Rename Album action
        print("Rename Album")
    }
        
    func deleteAlbum() {
        // Handle Delete Album action
        print("Delete Album")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToViewAlbumImage",
        let nextVC = segue.destination as? ViewAlbumImageVC {
            if let indexPaths = collectionView.indexPathsForSelectedItems {
                let imageIndex = indexPaths[0].row
                nextVC.selectedImage = allAlbums[albumName!]![imageIndex]
                collectionView.deselectItem(at: indexPaths[0], animated: false)
            }
        } else if segue.identifier == "segueToPlaybackSettings",
          let nextVC = segue.destination as? PlaybackSettingsVC {
            nextVC.selectedPhotos = self.selectedPhotos
        }
    }
}
