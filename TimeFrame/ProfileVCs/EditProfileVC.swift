//
//  EditProfileVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/15/24.
//

import UIKit

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var errorMessage = ""
    
    @IBOutlet weak var profilePicture: UIImageView!
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.layer.cornerRadius = 5
        logoutButton.layer.cornerRadius = 5
        // TODO: populate text field text with labels from previous screen
        
        profilePicture.layer.cornerRadius = profilePicture.layer.frame.height / 2
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            profilePicture.image = selectedImage
            // TODO: need change to be reflected on the previous VC (only if Save is pressed)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        if !(email.contains("@")) {
            errorMessage = "Invalid email address"
        }
        return errorMessage == ""
    }
    
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
        if errorMessage != "" {
            let controller = UIAlertController(
                title: "Error",
                message: errorMessage,
                preferredStyle: .alert
            )
            controller.addAction(UIAlertAction(title: "OK", style: .default))
            present(controller, animated: true)
        } else {
            // Save the data to user profile if all text fields are valid
            // Should probably put this in a separate function call
            // Go back to previous VC
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
