//
//  EditProfileVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/15/24.
//

import UIKit

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Data from Profile screen
    var delegate: UIViewController!
    var prevDisplayName = ""
    var prevUsername = ""
    var prevPicture: UIImage!

    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var errorMessage = ""
    
    @IBOutlet weak var profilePicture: UIImageView!
    var imagePicker = UIImagePickerController()
    var selectedImage: UIImage?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.layer.cornerRadius = 5
        logoutButton.layer.cornerRadius = 5
        
        // Populates text field with labels from profile screen
        displayNameTextField.text = prevDisplayName
        usernameTextField.text = prevUsername
        profilePicture.image = prevPicture
        
        // Circular crop for profile picture
        profilePicture.layer.cornerRadius = profilePicture.layer.frame.height / 2
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Displays an action sheet with 3 options: Take Picture, Choose from Library, Cancel
    @IBAction func editProfilePressed(_ sender: Any) {
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
            UIAlertAction(title: "Choose from Library", style: .default) { action in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        )
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(controller, animated: true)
    }
    
    // Sets profile picture in Edit Profile screen to selected picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            profilePicture.image = selectedImage
            self.selectedImage = selectedImage
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // Checks if entered email has valid format
    func isValidEmail(_ email: String) -> Bool {
        if !(email.contains("@")) {
            errorMessage = "Invalid email address"
        }
        return errorMessage == ""
    }
    
    // Checks if entered password has valid format
    func checkPassword(_ password: String) {
        if (password.count < 8) {
            errorMessage = "Password must be at least 8 characters"
        } else if (password == password.lowercased()) {
            errorMessage = "Password must contain at least 1 uppercase character"
        } else {
            let numberPredicate = NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*")
            if !(numberPredicate.evaluate(with: password)) {
                errorMessage = "Password must contain at least 1 number"
            }
            let symbolPredicate = NSPredicate(format: "SELF MATCHES %@", ".*[!&^%$#@()/]+.*$")
            if !(symbolPredicate.evaluate(with: password)) {
                errorMessage = "Password must contain at least 1 special character"
            }
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let displayName = displayNameTextField.text!
        let username = usernameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        if (displayName.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
            errorMessage = "Text fields cannot be empty"
        } else if isValidEmail(email){
            checkPassword(password)
        }
        // Displays error message alert if any text field is invalid
        if errorMessage != "" {
            let controller = UIAlertController(
                title: "Error",
                message: errorMessage,
                preferredStyle: .alert
            )
            controller.addAction(UIAlertAction(title: "OK", style: .default))
            present(controller, animated: true)
        // If all text fields are valid, updates changes in the Profile screen
        } else {
            let profileVC = delegate as! ProfileChanger
            profileVC.changeDisplayName(displayNameTextField.text!)
            profileVC.changeUsername(usernameTextField.text!)
            if selectedImage != nil {
                profileVC.changePicture(selectedImage!)
            }
            self.navigationController?.popViewController(animated: true)
        }
        errorMessage = ""
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        // alert controller pops up
        // deal with Firebase stuff
    }
    
    @IBAction func deleteAccountPressed(_ sender: Any) {
        // alert controller pops out that asks if the user is sure
        // then makes them type their username to confirm
        // deal with Firebase stuff
    }
    
    
    
    // TODO: add code to dismiss the keyboard
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
