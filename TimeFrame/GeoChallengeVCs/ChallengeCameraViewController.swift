//
//  ChallengeCameraViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 3/16/24.
//
// Project: TimeFrame
// EID: mas23586
// Course: CS371L

import AVFoundation
import UIKit

class ChallengeCameraViewController: UIViewController {
    // Capture session.
    var session: AVCaptureSession?
    
    // Photo output.
    let output = AVCapturePhotoOutput()
    
    // Video preview.
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    // Shutter button.
    private let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 10
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    // Image taken by camera.
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        previewLayer.backgroundColor = UIColor.systemRed.cgColor
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        
        checkCameraPermissions()
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        setCustomBackImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        shutterButton.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height - 100)
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // Request permission.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else {
                    return
                }
                
                DispatchQueue.main.async {
                    // Updating the UI.
                    self.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    private func setUpCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill // Make sure camera feed is not distorted.
                previewLayer.session = session
                session.startRunning()
                self.session = session
            } catch {
                print(error)
            }
        }
    }
    
    @objc private func didTapTakePhoto() {
        // TODO: can change camera settings here
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)

        let addPhotoVC = AddPhotoToChallengeViewController()
        addPhotoVC.modalPresentationStyle = .fullScreen
        self.present(addPhotoVC, animated: true, completion: nil)
    }
}

extension ChallengeCameraViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        
        // Stop running the camera.
        session?.stopRunning()
        
        self.image = UIImage(data: data)
    }
}


////
////  ChallengeCameraViewController.swift
////  TimeFrame
////
////  Created by Megan Sundheim on 3/16/24.
////
//// Project: TimeFrame
//// EID: mas23586
//// Course: CS371L
//
//import AVFoundation
//import UIKit
//
//class ChallengeCameraViewController: UIViewController {
//    // Capture session.
//    var session: AVCaptureSession?
//    
//    // Photo output.
//    let output = AVCapturePhotoOutput()
//    
//    // Video preview.
//    let previewLayer = AVCaptureVideoPreviewLayer()
//    
//    // Shutter button.
//    private let shutterButton: UIButton = {
//        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        button.layer.cornerRadius = 50
//        button.layer.borderWidth = 10
//        button.layer.borderColor = UIColor.white.cgColor
//        return button
//    }()
//    
//    // Image taken by camera.
//    var image: UIImage?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .black
//        previewLayer.backgroundColor = UIColor.systemRed.cgColor
//        view.layer.addSublayer(previewLayer)
//        view.addSubview(shutterButton)
//        
//        checkCameraPermissions()
//        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
//        setCustomBackImage()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        previewLayer.frame = view.bounds
//        shutterButton.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height - 100)
//    }
//    
//    private func checkCameraPermissions() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .notDetermined:
//            // Request permission.
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                guard granted else {
//                    return
//                }
//                
//                DispatchQueue.main.async {
//                    // Updating the UI.
//                    self.setUpCamera()
//                }
//            }
//        case .restricted:
//            break
//        case .denied:
//            break
//        case .authorized:
//            setUpCamera()
//        @unknown default:
//            break
//        }
//    }
//    
//    private func setUpCamera() {
//        let session = AVCaptureSession()
//        if let device = AVCaptureDevice.default(for: .video) {
//            do {
//                let input = try AVCaptureDeviceInput(device: device)
//                if session.canAddInput(input) {
//                    session.addInput(input)
//                }
//                
//                if session.canAddOutput(output) {
//                    session.addOutput(output)
//                }
//                
//                previewLayer.videoGravity = .resizeAspectFill // Make sure camera feed is not distorted.
//                previewLayer.session = session
//                session.startRunning()
//                self.session = session
//            } catch {
//                print(error)
//            }
//        }
//    }
//    
//    @objc private func didTapTakePhoto() {
//        // TODO: can change camera settings here
//        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
//
//        let addPhotoVC = AddPhotoToChallengeViewController()
//        addPhotoVC.modalPresentationStyle = .fullScreen
//        self.present(addPhotoVC, animated: true, completion: nil)
//    }
//}
//
//extension ChallengeCameraViewController : AVCapturePhotoCaptureDelegate {
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
//        guard let data = photo.fileDataRepresentation() else {
//            return
//        }
//        
//        // Stop running the camera.
//        session?.stopRunning()
//        
//        self.image = UIImage(data: data)
//    }
//}
//
