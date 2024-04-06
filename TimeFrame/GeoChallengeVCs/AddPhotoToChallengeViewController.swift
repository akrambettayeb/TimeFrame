//
//  AddPhotoToChallengeViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 3/16/24.
//
// Project: TimeFrame
// EID: mas23586
// Course: CS371L

import UIKit
import AVFoundation

class AddPhotoToChallengeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var previewView: UIImageView!
    
    var overlayView = UIImageView(image: UIImage(named: "InitialImagePlaceholder")) // TODO: replace
    let picker = UIImagePickerController()
    var cameraLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        setCustomBackImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !cameraLoaded {
            // Only load the camera once automatically.
            showCamera() // TODO: need to load new overlay image
        } else if previewView.image == nil {
            performSegue(withIdentifier: "CameraToTimeLapseSegue", sender: nil)
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
                return
            }
            
            cameraLoaded = true
            picker.sourceType = .camera
            picker.allowsEditing = false //TODO: add and delete photos from firebase
            picker.cameraCaptureMode = .photo //TODO: add overlay code to home screen
            overlayView.alpha = 0.4
            
            // Get bounds for camera preview.
            let screenSize = UIScreen.main.bounds.size
            let ratio: CGFloat = 4.0 / 3.0
            let cameraHeight: CGFloat = screenSize.width * ratio
            overlayView.frame = CGRect(x: 0, y: 121.5, width: screenSize.width, height: cameraHeight)
            
            overlayView.contentMode = .scaleAspectFill
            picker.cameraOverlayView = overlayView
            
            // Add observer to the user capturing a photo.
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidCaptureItem"), object:nil, queue:nil, using: { note in
                // Remove overlay.
                self.overlayView.alpha = 0
                self.picker.cameraOverlayView = self.overlayView
            })
            
            self.present(picker, animated: true, completion: nil)
        } else {
            // Not available, pop up an alert.
            let alertVC = UIAlertController(title: "No Camera Available", message: "Sorry, this device does not have a camera.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
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
    
    @IBAction func onRetakePhotoButtonPressed(_ sender: Any) {
        // Retake photo.
        showCamera()
        //TODO: delete old photo and save new photo
    }
}
