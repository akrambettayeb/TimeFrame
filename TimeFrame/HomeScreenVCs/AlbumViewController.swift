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

class AlbumViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var isMenuOpen = false
    var imagePicker = UIImagePickerController()
    var photoUrls = [String]() // Array to hold URLs of photos in Firestore
    var collectionView: UICollectionView!
    let reuseIdentifier = "PhotoCell"
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        // Set up navigation bar
        title = "Album"
        let addPhotoMenuItem = UIAction(title: "Add Photo", image: UIImage(systemName: "plus")) { _ in
            // Add Photo action
            self.addPhoto()
        }
        
        let createTimeframeMenuItem = UIAction(title: "Create Timeframe", image: UIImage(systemName: "plus")) { _ in
            // Create Timeframe action
            self.createTimeframe()
        }
        
        let renameAlbumMenuItem = UIAction(title: "Rename Album", image: UIImage(systemName: "pencil")) { _ in
            // Rename Album action
            self.renameAlbum()
        }
        
        let deleteAlbumMenuItem = UIAction(title: "Delete Album", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            // Delete Album action
            self.deleteAlbum()
        }
            
        let menu = UIMenu(title: "Album Menu", children: [addPhotoMenuItem, createTimeframeMenuItem, renameAlbumMenuItem, deleteAlbumMenuItem])
        
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: menu)
        
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
        // You can set up cell content here, like downloading and displaying images from URLs using Kingfisher or another library
        // For simplicity, we'll just set the cell's background color to black
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
        
    func createTimeframe() {
        // Handle Create Timeframe action
        print("Create Timeframe")
    }
        
    func renameAlbum() {
        // Handle Rename Album action
        print("Rename Album")
    }
        
    func deleteAlbum() {
        // Handle Delete Album action
        print("Delete Album")
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


