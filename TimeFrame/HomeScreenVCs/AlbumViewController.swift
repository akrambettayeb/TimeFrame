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

    
    @IBOutlet weak var settings: UIBarButtonItem!
    @IBOutlet weak var newItem: UIBarButtonItem!
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if !(parent?.isEqual(self.parent) ?? false) {
            print("Parent view loaded")
        }
        super.didMove(toParent: parent)
    }
    
    @IBAction func addItemPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        controller.addAction(
            UIAlertAction(title: "Take Picture", style: .default) { action in
                self.imagePicker.sourceType = .camera
                self.imagePicker.cameraFlashMode = .off
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        )
        controller.addAction(
            UIAlertAction(title: "Create TimeFrame", style: .default) { action in
                print("TimeFrame")
            }
        )
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(controller, animated: true)
    }
    
}
