//
//  CreateAlbumViewController.swift
//  TimeFrame
//
//  Created by Brandon Ling on 3/18/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class CreateAlbumViewController: UIViewController {
    
    @IBOutlet weak var albumNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
    }
    
    @IBAction func createAlbumButtonClicked(_ sender: UIButton) {
        guard let userID = (Auth.auth().currentUser?.uid),
        let albumName = albumNameTextField.text, !albumName.isEmpty else {
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let userRef = storageRef.child(String(userID))
        let albumRef = userRef.child(String(albumName))
    }
}
