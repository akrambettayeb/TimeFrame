//
//  OpenTimeframeVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/8/24.
//
//  Project: TimeFrame
//  EID: kz4696
//  Course: CS371L


import UIKit

class OpenTimeframeVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    var timeframeName: String!
    var timeframeImages: [UIImage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        shareButton.layer.cornerRadius = 5
        timeframeImages = allTimeframes[timeframeName]
        // Placeholder: sets all TimeFrames to have a static duration of 2.0 seconds for 1 iteration through all photos in the TimeFrame
        imageView.animationDuration = 2.0
        imageView.animationImages = timeframeImages
        imageView.startAnimating()
    }
    
    // Shares the TimeFrame as a GIF to the user's other apps when the "Share" button is tapped
    @IBAction func onShareTapped(_ sender: Any) {
        var shareItem: Any = ""
        let gifURL = UIImage.animatedGif(from: timeframeImages, from: 2.0/Float(timeframeImages.count))
        
        if gifURL != nil {
            shareItem = gifURL!
        } else {
            // Share first photo in array if there is an error generating the GIF
            shareItem = timeframeImages[0]
        }
        let activityController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}
