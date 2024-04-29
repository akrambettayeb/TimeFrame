//
//  EditProfileVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/15/24.
//
//  Project: TimeFrame
//  EID: kz4696
//  Course: CS371L


import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let ref = Database.database().reference()
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser!.uid
    
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
        
        // use auth current user's email
        emailTextField.text = Auth.auth().currentUser?.email
        emailTextField.isEnabled = false
        emailTextField.textColor = UIColor.lightGray
        passwordTextField.text = ""
        
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
        return allTimeframes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageGrid.dequeueReusableCell(withReuseIdentifier: imageCellID, for: indexPath) as! EditImageCell
        let index = allTimeframes.count - indexPath.row - 1
        let tfName = timeframeNames[index]
        let timeframe = allTimeframes[tfName]!
        let tfPublic = !(timeframe.isPrivate)
       
        // Configure eye button for each cell signifying public/private Timeframes
        cell.visibleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)  // private
        cell.visibleButton.setImage(UIImage(systemName: "eye.fill"), for: .selected) // public
        cell.visibleButton.isSelected = tfPublic
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .clear
        cell.visibleButton.configuration = config
        
        cell.imageView.image = timeframe.thumbnail
        cell.grayImage = cell.grayscaleImage(cell.imageView.image!)
        cell.coloredImage = cell.imageView.image
        if !tfPublic {
            cell.imageView.image = cell.grayImage
        }
        return cell
    }
    
    // Defines layout for the collection view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let collectionWidth = imageGrid.bounds.width
        let cellSize = (collectionWidth - 5) / 3
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        imageGrid.collectionViewLayout = layout
    }
    
    // Defines layout when there is only 1 cell in the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       if collectionView.numberOfItems(inSection: section) == 1 {
           let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
           return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width)
       }
       return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
                self.imagePicker.cameraDevice = .front
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
    
    func checkDisplayName(_ displayName: String) {
        let nameArray = displayName.split(separator: " ")
        if nameArray.count != 2 {
            errorMessage = "Display name must be a first and last name"
        }
    }
    
    func checkUsername(_ username: String) {
        // username length check
        if username.count > 30 {
            errorMessage = "Username must be less than 30 characters"
        }
        
        // username character check
        let usernameRegex = "^[a-zA-Z0-9._]+$"
        let usernameTest = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        if !usernameTest.evaluate(with: username) {
            errorMessage = "Username must contain only letters, numbers, periods, and underscores"
        }
        
        // unique username check
        let usersRef = ref.child("users")
        usersRef.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChild(username) {
                self.errorMessage = "Username is already taken"
            }
        })
    }
    
    func updatePublicTfs() {
        for indexPath in imageGrid.indexPathsForVisibleItems {
            if let cell = imageGrid.cellForItem(at: indexPath) as? EditImageCell {
                let index = allTimeframes.count - indexPath.row - 1
                let tfName = timeframeNames[index]
                // Check if TimeFrame privacy changed
                if cell.visibleButton.isSelected == allTimeframes[tfName]?.isPrivate {
                    let isPrivate = !(cell.visibleButton.isSelected)
                    allTimeframes[tfName]?.isPrivate = isPrivate
                    let timeframeRef = db.collection("users").document(userID).collection("timeframes").document(tfName)
                    timeframeRef.updateData([
                        "isPrivate": isPrivate
                    ]) { (error) in
                        if let error = error {
                            print("Error updating timeframe \(tfName): \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    func saveProfilePhotoUrlToFirestore(from downloadURL: String) {
        let userRef = db.collection("users").document(userID)
        userRef.setData([
            "profilePhotoURL": downloadURL
        ], merge: true) { error in
            if let error = error {
                print("Error updating profile photo for user \(self.userID): \(error.localizedDescription)")
            }
        }
    }
    
    func uploadProfilePhoto(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Invalid image data for profile picture. ")
            self.navigationController?.popViewController(animated: true)
            return
        }
        let photoFileName = "\(userID).jpg"
        let storageRef =  Storage.storage().reference().child("users").child(userID).child(photoFileName)
        print("Call to upload profile photo")
        storageRef.putData(imageData, metadata: nil) { [weak self] (metadata, error) in
            guard let self = self else {
                self?.navigationController?.popViewController(animated: true)
                return
            }
            if let error = error {
                print("Error uploading profile picture to Firebase storage: \(error.localizedDescription)")
            } else {
                storageRef.downloadURL { (url, error) in
                    if let downloadURL = url?.absoluteString {
                        print("ATTEMPT: save profile photo URL to Firestore")
                        self.saveProfilePhotoUrlToFirestore(from: downloadURL)
                    }
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    // Checks if text fields are valid, displays error message if invalid and saves profile changes if valid
    @IBAction func saveButtonPressed(_ sender: Any) {
        let displayName = displayNameTextField.text!
        let username = usernameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        if (displayName.isEmpty || username.isEmpty || email.isEmpty) {
            errorMessage = "Text fields cannot be empty"
        } else if isValidEmail(email) {
            checkDisplayName(displayName)
            checkUsername(username)
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
            updatePublicTfs()
            
            // update in Firebase Authentication
            let user = Auth.auth().currentUser

            // if password is not different, proceed to reauthenticate then update password
            if password != "" {
                let controller = UIAlertController(
                    title: "Confirm Password",
                    message: "Please enter your old password to confirm changes",
                    preferredStyle: .alert
                )
                controller.addTextField(configurationHandler: { textField in
                    textField.placeholder = "Enter old password"
                    textField.isSecureTextEntry = true // Make sure the password is not visible
                })
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                controller.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [weak self] _ in
                    // Grab the old password from the first textField in the alertController
                    guard let oldPassword = controller.textFields?.first?.text, let email = user?.email else {
                        return
                    }
                    let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
                    user?.reauthenticate(with: credential, completion: { _, error in
                        if let error = error {
                            // Perform error handling on the main thread
                            DispatchQueue.main.async {
                                self?.errorAlert("Error reauthenticating: \(error.localizedDescription)")
                            }
                        } else {
                            user?.updatePassword(to: password, completion: { error in
                                if let error = error {
                                    // Perform error handling on the main thread
                                    DispatchQueue.main.async {
                                        self?.errorAlert("Error updating password: \(error.localizedDescription)")
                                    }
                                } else {
                                    let successController = UIAlertController(
                                        title: "Success",
                                        message: "Password updated",
                                        preferredStyle: .alert
                                    )
                                    successController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                                        self?.dismiss(animated: true)
                                    }))
                                    DispatchQueue.main.async {
                                        self?.present(successController, animated: true)
                                    }
                                }
                            })
                        }
                    })
                }))
                present(controller, animated: true)
            }
            
            // Update username and display name in firebase database
            let usersRef = ref.child("users")
            
            let nameParts = displayName.split(separator: " ").map(String.init)
            let firstName = nameParts.first ?? ""
            let lastName = nameParts.dropFirst().joined(separator: " ")
            let email = Auth.auth().currentUser?.email ?? ""
            
            let userDict = ["email": email,
                            "username": username,
                            "firstName": firstName,
                            "lastName": lastName]
            usersRef.child(userID).setValue(userDict) { error, _ in
                if let error = error {
                    self.errorAlert("Error updating user: \(error)")
                } else {
                    let successController = UIAlertController(
                        title: "Success",
                        message: "Profile updated",
                        preferredStyle: .alert
                    )
                }
            }
            
            if selectedImage != nil {
                self.uploadProfilePhoto(image: selectedImage!)
                profileVC.changePicture(selectedImage!)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
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
                // Clear locally cached albums and Timeframes
                allAlbums = [String: [AlbumPhoto]]()
                albumNames = [String]()
                allTimeframes = [String: TimeFrame]()
                timeframeNames = [String]()
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
        
        // check that correct password is entered
        let password = controller.textFields![0].text!
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: user!.email!, password: password)
        user?.reauthenticate(with: credential) { (result, error) in
            if let error = error {
                self.errorAlert("Error reauthenticating user: \(error)")
            } else {
                
            }
        }
    }
    
    @IBAction func deleteAccountPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account?",
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
//            self.verifyDeleteAccount()
            self.deleteAccount()
        })
        present(controller, animated: true)
    }
    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        // Recursively delete the data in uid's document from the 'users' subcollection from Firestore
        let firestore = Firestore.firestore()
        let userDocRef = firestore.collection("users").document(uid)
        // First, delete the documents in the subcollections
        userDocRef.collection("albums").getDocuments { [self] (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                self.errorAlert("Error fetching subcollection documents: \(error!)")
                return
            }
            let group = DispatchGroup()
            for document in querySnapshot.documents {
                group.enter()
                document.reference.delete { error in
                    if let error = error {
                        self.errorAlert("Error deleting subcollection document: \(error)")
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                // All subcollection documents are deleted, now delete the user document
                userDocRef.delete { error in
                    if let error = error {
                        self.errorAlert("Error deleting user document: \(error)")
                    } else {
                        // User document and subcollections successfully deleted
                    }
                }
        }
            // Delete data from Realtime Database
            let realtimeRef = ref.child("users").child(uid)
            realtimeRef.removeValue { error, _ in
                if let error = error {
                    self.errorAlert("Error deleting account from Realtime Database: \(error)")
                    return
                }
                
                // Delete the user from Firebase Auth
                user.delete { error in
                    if let error = error {
                        self.errorAlert("Error deleting account: \(error)")
                    } else {
                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
