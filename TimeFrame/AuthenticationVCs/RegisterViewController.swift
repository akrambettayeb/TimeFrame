//
//  RegisterViewController.swift
//  TimeFrame
//
//  Created by Akram Bettayeb on 3/14/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCustomBackImage()
        errorMessageLabel.isHidden = true
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let username = usernameTextField.text, !username.isEmpty,
              let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            errorMessageLabel.text = "Please fill in all fields."
            errorMessageLabel.isHidden = false
            return
        }
        
        guard password == confirmPassword else {
            errorMessageLabel.text = "Passwords do not match."
            errorMessageLabel.isHidden = false
            return
        }
        
        // Check for unique username
        checkUsernameUnique(username) { isUnique in
            if !isUnique {
                self.errorMessageLabel.text = "Username is already taken. Please choose another."
                self.errorMessageLabel.isHidden = false
                return
            }
            
            // Create a new user if the username is unique
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.errorMessageLabel.text = error.localizedDescription
                    self.errorMessageLabel.isHidden = false
                } else {
                    // User was created successfully, store the additional fields
                    if let userId = authResult?.user.uid {
                        self.saveUserInfo(userId: userId, email: email, username: username, firstName: firstName, lastName: lastName)
                    }
                }
            }
        }
    }
    
    
    private func checkUsernameUnique(_ username: String, completion: @escaping (Bool) -> Void) {
        let usersRef = Database.database().reference().child("users")
        usersRef.queryOrdered(byChild: "username").queryEqual(toValue: username)
            .observeSingleEvent(of: .value, with: { snapshot in
                completion(!snapshot.exists())
            })
    }
    
    private func saveUserInfo(userId: String, email: String, username: String, firstName: String, lastName: String) {
        let usersRef = Database.database().reference().child("users")
        let userDict = ["email": email,
                        "username": username,
                        "firstName": firstName,
                        "lastName": lastName]
        usersRef.child(userId).setValue(userDict) { error, _ in
            if let error = error {
                self.errorMessageLabel.text = error.localizedDescription
                self.errorMessageLabel.isHidden = false
            } else {
                self.errorMessageLabel.isHidden = true
                self.showSuccessAlert()
            }
        }
    }
    
    private func showSuccessAlert() {
        let successAlert = UIAlertController(title: "Registration Successful", message: "You have been registered successfully!", preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "registerSegueToMainStoryboard", sender: self)
        }))
        self.present(successAlert, animated: true, completion: nil)
    }
}
