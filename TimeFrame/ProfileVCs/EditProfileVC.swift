//
//  EditProfileVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/15/24.
//
// Project: TimeFrame
// EID: kz4696
// Course: CS371L

import UIKit
import FirebaseAuth
import FirebaseDatabase

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
    
    @IBOutlet weak var imageGrid: UICollectionView!
    let imageCellID = "EditImageCell"
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        self.hideKeyboardWhenTappedAround()
        
        logoutButton.layer.cornerRadius = 5
        
        // Populates text field with labels from profile screen
        displayNameTextField.text = prevDisplayName
        usernameTextField.text = prevUsername
        profilePicture.image = prevPicture
        
        // TODO: remove temporary text
        emailTextField.text = prevUsername + "@gmail.com"
        passwordTextField.text = prevUsername.uppercased() + "@12345"
        
        // Needed to dismiss software keyboard
        displayNameTextField.delegate = self
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Circular crop for profile picture
        profilePicture.layer.cornerRadius = profilePicture.layer.frame.height / 2
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        imageGrid.dataSource = self
        imageGrid.delegate = self
        imageGrid.isScrollEnabled = false
        
        self.setGridSize(imageGrid)
        self.setProfileScrollHeight(scrollView, imageGrid)
        logoutButton.frame.origin.y = imageGrid.frame.origin.y + imageGrid.frame.height + 10
        deleteAccountButton.frame.origin.y = logoutButton.frame.origin.y + 60
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allGridImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageGrid.dequeueReusableCell(withReuseIdentifier: imageCellID, for: indexPath) as! EditImageCell
        let gridIndex = allGridImages.count - indexPath.row - 1
        let imageVisible = allGridImages[gridIndex].visible
       
        cell.visibleButton.isSelected = !imageVisible
        cell.visibleButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        cell.visibleButton.setImage(UIImage(systemName: "eye.slash"), for: .selected)
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .clear
        cell.visibleButton.configuration = config
        
        cell.imageView.image = allGridImages[gridIndex].image
        cell.grayImage = cell.grayscaleImage(cell.imageView.image!)
        cell.coloredImage = cell.imageView.image
        if !imageVisible {
            cell.imageView.image = cell.grayImage
        }
        return cell
    }

    // Sets minimum spacing between cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    // Sets cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numCells = 3.0
        let viewWidth = collectionView.bounds.width - (numCells - 1) * 2.0
        let cellSize = viewWidth / numCells - 0.01
        return CGSize(width: cellSize, height: cellSize)
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
    
    func updateVisibleImagesArray() {
        for indexPath in imageGrid.indexPathsForVisibleItems {
            if let cell = imageGrid.cellForItem(at: indexPath) as? EditImageCell {
                let gridIndex = allGridImages.count - indexPath.row - 1
                allGridImages[gridIndex].visible = !cell.visibleButton.isSelected
            }
        }
    }
    
    // Checks if text fields are valid, displays error message if invalid and saves profile changes if valid
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
            updateVisibleImagesArray()
            if selectedImage != nil {
                profileVC.changePicture(selectedImage!)
                allGridImages.append(ProfileGridImage(selectedImage!))
            }
            self.navigationController?.popViewController(animated: true)
        }
        errorMessage = ""
    }
    
    func errorAlert(_ errorMessage: String) {
        let errorController = UIAlertController(
            title: "Error",
            message: errorMessage,
            preferredStyle: .alert
        )
        errorController.addAction(UIAlertAction(title: "OK", style: .default))
        present(errorController, animated: true)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addAction(UIAlertAction(title: "Logout", style: .default) { _ in
            do {
                try Auth.auth().signOut()
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            } catch let signOutError as NSError {
                self.errorAlert("Error signing out: \(signOutError)")
            }
        })
        present(controller, animated: true)
    }
    
    // Displays an alert controller requiring the user to enter password to confirm deletion
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
                                           style: .destructive) { _ in
//            self.verifyDeleteAccount()
            do {
                let user = Auth.auth().currentUser
                user?.delete() { error in
                    if let error = error {
                        self.errorAlert("Error deleting account: \(error)")
                    }
                }
                let usersRef = Database.database().reference().child("username")
                usersRef.queryOrdered(byChild: "username").queryEqual(toValue: user?.uid).observeSingleEvent(of: .value, with: { snapshot in
                    if let userSnapshot = snapshot.children.allObjects.first as? DataSnapshot {
                        userSnapshot.ref.removeValue()
                    }
                })
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
        })
        present(controller, animated: true)
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
