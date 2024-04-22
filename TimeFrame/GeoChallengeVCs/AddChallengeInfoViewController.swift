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

protocol UpdateCameraLoaded {
    func updateCameraLoaded(cameraLoaded: Bool)
}

protocol UpdatePreview {
    func updatePreview(image: UIImage)
}

class AddChallengeInfoViewController: UIViewController, UITextFieldDelegate, UpdateCameraLoaded, UpdatePreview {
    //TODO: add dismiss keyboard
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var locationNameField: UITextField!
    
    var cameraLoaded = false
    var challengeLocation: MKPointAnnotation?
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationNameField.delegate = self
        setCustomBackImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !cameraLoaded {
            // Only load the camera once automatically.
            performSegue(withIdentifier: "AddInitialPhotoSegue", sender: self)
        } else if previewView.image == nil {
            // Go back to Map Screen.
            dismiss(animated: true)
        }
    }
    
    @IBAction func onSubmitButtonPressed(_ sender: Any) {
        //TODO: check for fields
        challengeLocations.append(challengeLocation!)
        dismiss(animated: true)
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
    
    func updateCameraLoaded(cameraLoaded: Bool) {
        self.cameraLoaded = cameraLoaded
    }
    
    func updatePreview(image: UIImage) {
        self.previewView.image = image
    }
}
