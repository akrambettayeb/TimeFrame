//
//  OpenTimeframeVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/8/24.
//

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
        imageView.animationDuration = 2.0
        imageView.animationImages = timeframeImages
        imageView.startAnimating()
    }
    
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
