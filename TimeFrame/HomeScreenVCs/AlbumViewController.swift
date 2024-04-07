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

public var fetchedPhotos: [UIImage] = []

class AlbumViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var collectionView: UICollectionView!
    var photoURLs = [String]()
    var albumName: String?
    let reuseIdentifier = "PhotoCell"
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        self.createMenu()

        collectionView.dataSource = self
        collectionView.delegate = self
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
            // TODO: allow user to select pictures in the album
            self.performSegue(withIdentifier: "segueToPlaybackSettings", sender: self)
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: menu)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "TabBarPurple")
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
                    self?.photoURLs.append(photoUrl)
                }
            }
                
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoURLs.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AlbumCell
        // Configure cell
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.clipsToBounds = true
        cell.selectButton.setImage(UIImage(systemName: "circle"), for: .normal)
        cell.selectButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .selected)
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .clear
        cell.selectButton.configuration = config
        cell.selectButton.isHidden = false  // TODO: set to true
        
        let imageUrl = photoURLs[indexPath.item]
        // You may want to use a library like Kingfisher to load images asynchronously
        // For simplicity, we assume the image URL is valid and load synchronously
        if let url = URL(string: imageUrl), let imageData = try? Data(contentsOf: url) {
            cell.imageView.image = UIImage(data: imageData)
            fetchedPhotos.append(cell.imageView.image!)
        }
        return cell
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
                self?.photoURLs.append(downloadURL)
                self?.collectionView.reloadData()
            }
        }
    }
}
