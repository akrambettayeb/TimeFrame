//
//  AlbumViewController.swift
//  TimeFrame
//
//  Created by Brandon Ling on 3/18/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AlbumViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var imagePicker = UIImagePickerController()
    
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
    
    
}
