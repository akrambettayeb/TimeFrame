//
//  RegisterViewController.swift
//  TimeFrame
//
//  Created by Akram Bettayeb on 3/14/24.
//
//  Project: TimeFrame
//  EID: aab4889
//  Course: CS371L


import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController, UITextFieldDelegate {

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
        
        emailTextField.delegate = self
        usernameTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        passwordTextField.textContentType = .oneTimeCode
        confirmPasswordTextField.textContentType = .oneTimeCode
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
                
        // username length check
        if username.count > 30 {
            errorMessageLabel.text = "Username must be less than 30 characters."
            errorMessageLabel.isHidden = false
            return
        }
        
        // username character check
        let usernameRegex = "^[a-zA-Z0-9._]+$"
        let usernameTest = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        if !usernameTest.evaluate(with: username) {
            errorMessageLabel.text = "Username must contain only letters, numbers, periods, and underscores."
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
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registerSegueToMainStoryboard" {
            emailTextField.text = ""
            usernameTextField.text = ""
            firstNameTextField.text = ""
            lastNameTextField.text = ""
            passwordTextField.text = ""
            confirmPasswordTextField.text = ""
        }
    }
}
