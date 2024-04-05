//
//  AlbumVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/1/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class AlbumVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        self.createMenu()
    }
    
    // Sets up dropdown items for navigation item in top-right corner
    func createMenu() {
        title = "Album"
        let addPhotoItem = UIAction(title: "Add Photo", image: UIImage(systemName: "plus")) { _ in
            self.addPhoto()
        }
        let createTimeframeItem = UIAction(title: "Create TimeFrame", image: UIImage(systemName: "plus")) { _ in
            self.goToPlaybackSettings()
        }
        let menu = UIMenu(title: "Album Menu", children: [addPhotoItem, createTimeframeItem])
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: menu)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "TabBarPurple")
    }
    
    func addPhoto() {
        print("Add Photo option clicked!")
    }
    
    func goToPlaybackSettings() {
        print("Add TimeFrame option clicked!")
        performSegue(withIdentifier: "segueToPlaybackSettings", sender: self)
    }

}



/*

class AlbumViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var isMenuOpen = false
    var imagePicker = UIImagePickerController()
    var photoUrls = [String]() // Array to hold URLs of photos in Firestore
    var collectionView: UICollectionView!
    let reuseIdentifier = "PhotoCell"
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        // Fetch photo URLs from Firestore
        //fetchPhotoUrls()
        
        }
    
    func fetchPhotoUrls() {
        let db = Firestore.firestore()
        let photosCollection = db.collection("photos")
        
        photosCollection.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching photos: \(error.localizedDescription)")
            } else {
                guard let documents = snapshot?.documents else { return }
                
                for document in documents {
                    if let photoUrl = document.data()["url"] as? String {
                        // Append photo URL to photoUrls array
                        self.photoUrls.append(photoUrl)
                    }
                }
                    
                // Reload collection view to display fetched photos
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoUrls.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = .black
        return cell
    }
        
    // MARK: - Collection View Delegate
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle cell selection
    }
    
    func addPhoto() {
        // Handle Add Photo action
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
        // Use the captured photo
        // Here you can save the image or use it as required
        // You might want to present a confirmation dialog to the user before saving the image
        // For now, we just dismiss the image picker
        dismiss(animated: true, completion: nil)
        }
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // User cancelled the image picker
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImageToFirestore(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Failed to convert image to data")
            return
        }
        
        let photoFilename = "\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child("photos").child(photoFilename)
        
        // Upload image data to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
                return
            }
                
            // Get download URL for the uploaded image
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                
                if let downloadURL = url?.absoluteString {
                    // Save download URL to Firestore
                    self.saveImageUrlToFirestore(downloadURL: downloadURL)
                }
            }
        }
    }
    
    func saveImageUrlToFirestore(downloadURL: String) {
        let photosCollection = db.collection("photos")
        
        // Add photo URL to Firestore
        photosCollection.addDocument(data: ["url": downloadURL]) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added with ID: \(photosCollection.document().documentID)")
                // Refresh the collection view after adding the new photo
                self.fetchPhotoUrls()
            }
        }
    }
    
}

*/
