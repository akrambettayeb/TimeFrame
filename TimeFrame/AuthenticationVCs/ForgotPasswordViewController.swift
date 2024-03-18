//
//  ForgotPasswordViewController.swift
//  TimeFrame
//
//  Created by Akram Bettayeb on 3/15/24.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessageLabel.isHidden = true
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
            errorMessageLabel.text = "Please enter your email address."
            errorMessageLabel.isHidden = false
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] (error) in
            guard let self = self else { return }

            if let error = error {
                self.errorMessageLabel.text = error.localizedDescription
                self.errorMessageLabel.isHidden = false
            } else {
                let alert = UIAlertController(title: "Password Reset Email Sent", message: "An email has been sent to \(email) with instructions on how to reset your password.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func returnToLoginButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
