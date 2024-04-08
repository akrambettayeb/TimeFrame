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

class AddChallengeInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //TODO: add dismiss keyboard
    @IBOutlet weak var previewView: UIImageView!
    
    let picker = UIImagePickerController()
    var cameraLoaded = false
    var challengeLocation: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        setCustomBackImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !cameraLoaded {
            // Only load the camera once automatically.
            showCamera()
        } else if previewView.image == nil {
            // Go back to Map Screen.
            performSegue(withIdentifier: "AddChallengeToMapSegue", sender: self)
        }
    }
    
    func showCamera() {
        // Check availability of camera.
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) {
                    accessGranted in guard accessGranted == true
                    else {return}
                }
            case .authorized:
                break
            default:
                print("Access denied.") //TODO: show some error and segue if access denied
                performSegue(withIdentifier: "AddChallengeToMapSegue", sender: self)
                return
            }
            
            cameraLoaded = true
            picker.sourceType = .camera
            picker.allowsEditing = false //TODO: add and delete photos from firebase
            picker.cameraCaptureMode = .photo //TODO: add overlay code to home screen
            
            self.present(picker, animated: true, completion: nil)
        } else {
            // Not available, pop up an alert.
            let alertVC = UIAlertController(title: "No Camera Available", message: "Sorry, this device does not have a camera.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.dismiss(animated: true)
            }
            alertVC.addAction(okAction)
            present(alertVC, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[.originalImage] as! UIImage
        
        // Shrink to visible size.
        previewView.contentMode = .scaleAspectFit
        
        // Put the image in the imageView.
        previewView.image = chosenImage
        
        // Dismiss this popover.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSubmitButtonPressed(_ sender: Any) {
        //TODO: check for fields
        challengeLocations.append(challengeLocation!)
        dismiss(animated: true)
    }
    
    @IBAction func onBackButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
