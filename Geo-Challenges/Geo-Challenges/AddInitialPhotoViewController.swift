//
//  AddInitialPhotoViewController.swift
//  Geo-Challenges
//
//  Created by Megan Sundheim on 3/7/24.
//

import UIKit
import AVFoundation

// MARK: Camera API code from https://medium.com/@sukiasyan.official/ios-tutorial-building-a-full-screen-camera-with-swift-xcode-part-1-cb68bc9b248f.

class AddInitialPhotoViewController: UIViewController {
    
    // Set up camera. (from Medium tutorial).
    let captureSession = AVCaptureSession()
    var backFacingCamera: AVCaptureDevice?
    var frontFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice!
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // Set up device output. (from Medium tutorial).
    var stillImageOutput: AVCapturePhotoOutput!
    var stillImage: UIImage?
    
    @IBOutlet weak var cameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // From Medium tutorial.
    private func configure() {
        // Preset the session for taking photo in full resolution.
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        // Get the front and back-facing camera for taking photos.
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)
         
        for device in deviceDiscoverySession.devices {
            if device.position == .back {
                backFacingCamera = device
            } else if device.position == .front {
                frontFacingCamera = device
            }
        }
         
        currentDevice = backFacingCamera
         
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice) else {
            return
        }
        
        // Configure the session with the output for capturing still images.
        stillImageOutput = AVCapturePhotoOutput()
        
        // Configure the session with the input and the output devices.
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(stillImageOutput)
        
        // Provide a camera preview.
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
                 
        // Bring the camera button to front.
        view.bringSubviewToFront(cameraButton) // TODO: add camera button
        captureSession.startRunning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
