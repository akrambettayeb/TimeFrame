//
//  EditProfileVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/15/24.
//

import UIKit

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
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
    
    var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        saveButton.layer.cornerRadius = 5
        logoutButton.layer.cornerRadius = 5
        
        // Populates text field with labels from profile screen
        displayNameTextField.text = prevDisplayName
        usernameTextField.text = prevUsername
        profilePicture.image = prevPicture
        
        // Needed to dismiss software keyboard
        displayNameTextField.delegate = self
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
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
       let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let emailPred = NSPredicate(format:"SELF MATCHES %@",emailRegEx)
       let isValid = emailPred.evaluate(with: email)
        if !isValid {
            errorMessage = "Invalid email address"
        }
        return isValid
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
        } else if isValidEmail(email) {
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
                profileVC.changeCellImage(selectedImage!)
            }
            self.navigationController?.popViewController(animated: true)
        }
        errorMessage = ""
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addAction(UIAlertAction(title: "Logout", style: .default))
        present(controller, animated: true)
        
        // TODO: firebase stuff
    }
    
    func verifyDeleteAccount() {
        let controller = UIAlertController(
            title: "Confirm Account Deletion",
            message: "Please enter your password to confirm you want to delete your account. ",
            preferredStyle: .alert
        )
        controller.addTextField(configurationHandler: {
            (textField) in textField.placeholder = "Enter password"
        })
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addAction(UIAlertAction(title: "Confirm", style: .destructive))
        present(controller, animated: true)
        
        // TODO: check that correct password is entered
    }
    
    @IBAction func deleteAccountPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account?",
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addAction(UIAlertAction(title: "Delete", 
                                           style: .destructive) { action in
            self.verifyDeleteAccount()
        })
        present(controller, animated: true)
        
        // TODO: firebase stuff
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
