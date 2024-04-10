//
//  ViewTimeFrameVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/1/24.
//
//  Project: TimeFrame
//  EID: kz4696
//  Course: CS371L


import Foundation
import UIKit
import UniformTypeIdentifiers

class ViewTimeframeVC: UIViewController {
    var timeframeName: String!
    var isPublic: Bool!
    var isFavorite: Bool!
    var isReversed: Bool!
    var selectedDate: String!
    var selectedSpeed: String!
    var selectedPhotos: [UIImage]!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    var imageDuration: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        self.title = timeframeName
        shareButton.layer.cornerRadius = 5
        animateImage()
    }
    
    func animateImage() {
        if isReversed {
            selectedPhotos = selectedPhotos.reversed()
        }
        let speedComponents = selectedSpeed.components(separatedBy: " ")
        let actualSpeed = Float(speedComponents[0])!
        let gifDuration = Float(selectedPhotos.count) / actualSpeed
        // Calculates the duration for each image
        imageDuration = gifDuration / Float(selectedPhotos.count)
        imageView.animationDuration = TimeInterval(gifDuration)
        imageView.animationImages = selectedPhotos
        imageView.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageView.animationImages = nil   // Release the memory from animating images
    }
    
    // Adds the TimeFrame to the local array of all created TimeFrames and unwind segues back to the main home screen
    @IBAction func onSaveTapped(_ sender: UIBarButtonItem) {
        allTimeframes[timeframeName] = selectedPhotos
        timeframeNames.append(timeframeName)
        performSegue(withIdentifier: "unwindViewTimeframeToHome", sender: self)
    }
    
    // Shares the TimeFrame as a GIF to the user's other apps when the "Share" button is tapped
    @IBAction func onShareTapped(_ sender: UIButton) {
        var shareItem: Any = ""
        let gifURL = UIImage.animatedGif(from: selectedPhotos, from: imageDuration)
        
        if gifURL != nil {
            shareItem = gifURL!
        } else {
            // Share first photo in array if there is an error generating the GIF
            shareItem = selectedPhotos[0]
        }
        let activityController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}
