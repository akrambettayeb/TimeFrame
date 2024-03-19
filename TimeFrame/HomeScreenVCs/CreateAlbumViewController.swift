//
//  CreateAlbumViewController.swift
//  TimeFrame
//
//  Created by Brandon Ling on 3/18/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class CreateAlbumViewController: UIViewController {
    
    @IBOutlet weak var albumNameTextField: UITextField!
    
    private var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
    }
    
    @IBAction func createAlbumButtonClicked(_ sender: UIButton) {
        guard let userID = Auth.auth().currentUser?.uid,
              let albumName = albumNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !albumName.isEmpty else {
            let alert = UIAlertController(title: "Invalid Album Name", message: "Please enter a valid album name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        
        let albumQuery = db.collection("users").document(userID).collection("albums").whereField("name", isEqualTo: albumName)
        
        albumQuery.getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                let alert = UIAlertController(title: "Error", message: "Failed to create album due to an error.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            } else if querySnapshot!.isEmpty {
                self?.db.collection("users").document(userID).collection("albums").document(albumName).setData(["name": albumName, "creationDate": FieldValue.serverTimestamp()]) { error in
                    if let error = error {
                        print("Error creating album: \(error.localizedDescription)")
                        let alert = UIAlertController(title: "Error", message: "Failed to create album due to an error.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    } else {
                        print("Album created successfully!")
                        let alert = UIAlertController(title: "Success", message: "Album created successfully!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            self?.performSegue(withIdentifier: "createToAlbumSeg", sender: nil)
                        })
                        self?.present(alert, animated: true)
                    }
                }
            } else {
                let alert = UIAlertController(title: "Album Exists", message: "An album with this name already exists. Please choose a different name.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
}
