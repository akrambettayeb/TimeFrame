//
//  RegisterViewController.swift
//  TimeFrame
//
//  Created by Akram Bettayeb on 3/14/24.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCustomBackImage()
        errorMessageLabel.isHidden = true
    }
    
    // Set custom back button
    func setCustomBackImage() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "arrow.backward")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "arrow.backward")
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            // Handle empty fields
            errorMessageLabel.text = "Please fill in all fields."
            errorMessageLabel.isHidden = false
            return
        }
        
        guard password == confirmPassword else {
            errorMessageLabel.text = "Passwords do not match."
            errorMessageLabel.isHidden = false
            return
        }
        
        // Create a new user
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessageLabel.text = error.localizedDescription
                self.errorMessageLabel.isHidden = false
            } else {
                // User was created successfully, TODO: store the first name and last name, username
                
                self.errorMessageLabel.text = ""
                self.errorMessageLabel.isHidden = true
                
                
                let successAlert = UIAlertController(title: "Registration Successful", message: "You have been registered successfully!", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    // Trigger the segue only after the user has dismissed the alert
                    self.performSegue(withIdentifier: "registerSegueToMainStoryboard", sender: self)
                }))
                self.present(successAlert, animated: true, completion: nil)
            }
        }
    }
}
