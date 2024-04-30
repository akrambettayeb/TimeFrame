//
//  AddChallengeInfoViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 3/16/24.
//
// Project: TimeFrame
// EID: mas23586
// Course: CS371L

import UIKit
import AVFoundation
import MapKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

protocol UpdatePreview {
    func updatePreview(image: UIImage)
}

class AddChallengeInfoViewController: UIViewController, UITextFieldDelegate, UpdatePreview {
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var locationNameField: UITextField!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var cameraLoaded = false
    var challengeLocation: MapPin?
    var delegate: UIViewController!
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationNameField.delegate = self
        setCustomBackImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset fields.
        locationNameField.text = ""
        endDatePicker.date = .now
        
        // Update current date.
        currentDateLabel.text = getDateString(date: .now)
        endDatePicker.minimumDate = .now
        
        if !cameraLoaded {
            // Only load the camera once automatically.
            cameraLoaded = true
            performSegue(withIdentifier: "AddInitialPhotoSegue", sender: self)
        } else if previewView.image == nil {
            // Go back to Map Screen.
            dismiss(animated: true)
        }
    }
    
    @IBAction func onSubmitButtonPressed(_ sender: Any) {
        // Check that location name and challenge dates are selected and valid.
        if locationNameField.text!.count == 0 {
            let errorAlert = UIAlertController(title: "Cannot create challenge", message: "Missing location name.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            errorAlert.addAction(okAction)
            present(errorAlert, animated: true)
        } else {
            let challengeImage = ChallengeImage(image: previewView.image!, numViews: 1, numLikes: 0, numFlags: 0, hidden: false, capturedTimestamp: .now)
            let challengeToWrite = Challenge(name: locationNameField.text!, coordinate: challengeLocation!.coordinate, startDate: .now, endDate: endDatePicker.date, numViews: 1, numLikes: 0, album: [challengeImage])
            
            // Write challenge to Firestore.
            let ref = db.collection("geochallenges").addDocument(data: [
            "name": challengeToWrite.name!,
            "coordinate": GeoPoint(latitude: challengeToWrite.coordinate.latitude, longitude: challengeToWrite.coordinate.longitude),
            "startDate": Timestamp(date: challengeToWrite.startDate),
            "endDate": Timestamp(date: challengeToWrite.endDate),
            "numViews": challengeToWrite.numViews,
            "numLikes": challengeToWrite.numLikes
            ])
            challengeToWrite.challengeID = ref.documentID

            print("Document added with ID: \(ref.documentID)")
            
            let photoRef = db.collection("geochallenges").document(ref.documentID).collection("album").addDocument(data: [:]) { [weak self] (error) in
                if let error = error {
                    print("Error adding document: \(error.localizedDescription)")
                }
            }
            
            let storageRef = storage.reference().child("geochallenges")
            let albumRef = storageRef.child(ref.documentID + "/" + photoRef.documentID)

            if let imageData = previewView.image!.jpegData(compressionQuality: 0.5) {
                albumRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
                    } else {
                        albumRef.downloadURL { (url, error) in
                            if let downloadURL = url?.absoluteString {
                                challengeImage.url = downloadURL
                                self.saveImageUrlToFirestore(downloadURL: downloadURL, albumName: ref.documentID, photoID: photoRef.documentID, challengeImage: challengeImage)
                            }
                        }
                    }
                }
            }
            
            challengeImage.documentID = photoRef.documentID
            challengeToWrite.album = [challengeImage]
            challenges.append(challengeToWrite)
            let mapVC = delegate as! MapViewController
            mapVC.addMapPin(challenge: challengeToWrite)
            
            dismiss(animated: true)
        }
    }
    
    func saveImageUrlToFirestore(downloadURL: String, albumName: String, photoID: String, challengeImage: ChallengeImage) {
        db.collection("geochallenges").document(albumName).collection("album").document(photoID).setData(["url": downloadURL, "numViews": 1, "numLikes": 0, "numFlags": 0, "hidden": false, "capturedTimestamp": Timestamp(date: challengeImage.capturedTimestamp)]) { [weak self] (error) in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added successfully")
            }
        }
    }
    
    @IBAction func onBackButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // Called when 'return' key pressed.
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddInitialPhotoSegue",
           let destination = segue.destination as? AddInitialPhotoViewController {
            destination.delegate = self
        }
    }
    
    func updatePreview(image: UIImage) {
        self.previewView.image = image
    }
    
    
}
