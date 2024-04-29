//
//  LoginScreenViewController.swift
//  TimeFrame
//
//  Created by Akram Bettayeb on 3/13/24.
//
//  Project: TimeFrame
//  EID: aab4889
//  Course: CS371L


import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        navigationItem.backBarButtonItem?.tintColor = .white
        errorMessageLabel.isHidden = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil && self.isViewLoaded && self.view.window != nil {
                self.performSegue(withIdentifier: "loginSegueToMainStoryboard", sender: nil)
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
            }
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            errorMessageLabel.text = "Please enter your email and password."
            errorMessageLabel.isHidden = false
            return
        }

        // Perform login using Firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                // Handle error - show error message
                self.errorMessageLabel.text = error.localizedDescription
                self.errorMessageLabel.isHidden = false
            } else {
                // Login was successful, perform segue to Main.storyboard
                self.performSegue(withIdentifier: "loginSegueToMainStoryboard", sender: self)
            }
        }
    }

    @IBAction func forgotPasswordButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "forgotPasswordSeg", sender: self)
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
        emailTextField.text = ""
        passwordTextField.text = ""
        errorMessageLabel.isHidden = true
        
        // If user is logged in, fetch all albums and populate the home screen collection views
        if segue.identifier == "loginSegueToMainStoryboard",
           let mainVC = segue.destination as? UITabBarController {
            guard let homeNav = mainVC.viewControllers?.first as? UINavigationController else {
                return
            }
            guard let homeVC = homeNav.visibleViewController as? ImageLoader else {
                return
            }
            
            // Create a dispatch group to wait for album, timeframe, and profile pic fetching
            let dispatchGroup = DispatchGroup()
            
            // Fetch all albums
            dispatchGroup.enter()
            self.fetchAllAlbums(for: self.db) { fetchedAlbums in
                allAlbums = fetchedAlbums
                albumNames = allAlbums.keys.sorted()
                homeVC.updateAlbums()
                dispatchGroup.leave()
            }
            
            // Fetch all timeframes
            dispatchGroup.enter()
            self.fetchAllTimeframesFromFirestore(for: self.db) { fetchedTimeframes in
                allTimeframes = fetchedTimeframes
                timeframeNames = allTimeframes.keys.sorted()
                homeVC.updateTimeframes()
                dispatchGroup.leave()
            }
            
            // Fetch profile picture
            guard let profileVC = mainVC.viewControllers?[3] as? UINavigationController else {
                print("Unable to get profileVC as navigation controller")
                return
            }
            guard let profileChanger = profileVC.viewControllers[0] as? ProfileChanger else {
                print("Unable to cast as ProfileChanger")
                return
            }
            guard let userID = Auth.auth().currentUser?.uid else {
                print("User not authenticated, exiting. ")
                return
            }
            dispatchGroup.enter()
            self.fetchProfilePhoto(for: userID) { fetchedPhoto in
                profilePic = fetchedPhoto
                profileChanger.changePicture(fetchedPhoto!)
                dispatchGroup.leave()
            }
            
            // Notify when both albums, timeframes, and profile picture have been fetched
            dispatchGroup.notify(queue: .main) {
                // Perform any additional actions after fetching both albums and timeframes
                // For example, you can reload data or update UI elements
            }
        }
    }
}
