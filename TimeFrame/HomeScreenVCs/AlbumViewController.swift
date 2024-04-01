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

class AlbumViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var albumName: String?
    var photoUrls = [String]()
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
    
    func fetchPhotoUrls(for albumName: String) {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("User not authenticated")
                return
            }
            
            db.collection("users").document(userID).collection("albums").document(albumName).collection("photos").getDocuments { [weak self] (snapshot, error) in
                if let error = error {
                    print("Error fetching photos: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                for document in documents {
                    if let photoUrl = document.data()["url"] as? String {
                        self?.photoUrls.append(photoUrl)
                    }
                }
                    
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return photoUrls.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
            // Configure cell
            let imageView = UIImageView(frame: cell.bounds)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            let imageUrl = photoUrls[indexPath.item]
            // You may want to use a library like Kingfisher to load images asynchronously
            // For simplicity, we assume the image URL is valid and load synchronously
            if let url = URL(string: imageUrl), let imageData = try? Data(contentsOf: url) {
                imageView.image = UIImage(data: imageData)
            }
            cell.addSubview(imageView)
            return cell
        }
    
    @objc func addPhoto() {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                uploadPhoto(image: image)
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
    
    func saveImageUrlToFirestore(downloadURL: String, albumName: String) {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("User not authenticated")
                return
            }
            
            let photoData: [String: Any] = ["url": downloadURL]
            db.collection("users").document(userID).collection("albums").document(albumName).collection("photos").addDocument(data: photoData) { [weak self] (error) in
                if let error = error {
                    print("Error adding document: \(error.localizedDescription)")
                } else {
                    print("Document added successfully")
                    self?.photoUrls.append(downloadURL)
                    self?.collectionView.reloadData()
                }
            }
        }
    
//    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
//        imagePicker.delegate = self
//        imagePicker.sourceType = sourceType
//        imagePicker.allowsEditing = true
//        present(imagePicker, animated: true, completion: nil)
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[.editedImage] as? UIImage {
//        // Use the captured photo
//        // Here you can save the image or use it as required
//        // You might want to present a confirmation dialog to the user before saving the image
//        // For now, we just dismiss the image picker
//        dismiss(animated: true, completion: nil)
//        }
//    }
//        
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        // User cancelled the image picker
//        dismiss(animated: true, completion: nil)
//    }
//    
//    func uploadImageToFirestore(image: UIImage) {
//        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
//            print("Failed to convert image to data")
//            return
//        }
//        
//        let photoFilename = "\(UUID().uuidString).jpg"
//        let storageRef = storage.reference().child("photos").child(photoFilename)
//        
//        // Upload image data to Firebase Storage
//        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
//            if let error = error {
//                print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
//                return
//            }
//                
//            // Get download URL for the uploaded image
//            storageRef.downloadURL { (url, error) in
//                if let error = error {
//                    print("Error getting download URL: \(error.localizedDescription)")
//                    return
//                }
//                
//                if let downloadURL = url?.absoluteString {
//                    // Save download URL to Firestore
//                    self.saveImageUrlToFirestore(downloadURL: downloadURL)
//                }
//            }
//        }
//    }
//    
//    func saveImageUrlToFirestore(downloadURL: String) {
//        let photosCollection = db.collection("photos")
//        
//        // Add photo URL to Firestore
//        photosCollection.addDocument(data: ["url": downloadURL]) { error in
//            if let error = error {
//                print("Error adding document: \(error.localizedDescription)")
//            } else {
//                print("Document added with ID: \(photosCollection.document().documentID)")
//                // Refresh the collection view after adding the new photo
//                self.fetchPhotoUrls()
//            }
//        }
//    }
    
}


