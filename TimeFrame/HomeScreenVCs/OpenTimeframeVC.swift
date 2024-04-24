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
    var timeframe: TimeFrame!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        shareButton.layer.cornerRadius = 5
//        timeframe = allTimeframes[timeframeName]
//        displayGIF(from: timeframe.url)
//        timeframeImages = allTimeframes[timeframeName]
//        // Placeholder: sets all TimeFrames to have a static duration of 2.0 seconds for 1 iteration through all photos in the TimeFrame
//        imageView.animationDuration = 2.0
//        imageView.animationImages = timeframeImages
//        imageView.startAnimating()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.imageView.animationImages = nil   // Release the memory from animating images
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timeframe = allTimeframes[timeframeName]
        print("TimeFrame name: \(timeframe.name)")
        print("TimeFrame url: \(timeframe.url)")
        self.imageView.stopAnimating()
        self.imageView.animationImages = nil
        displayGIF(from: timeframe.url, from: timeframe.selectedSpeed)
    }
    
    func displayGIF(from url: URL, from speed: Float) {
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: url),
               let source = CGImageSourceCreateWithData(imageData as CFData, nil) {
                let count = CGImageSourceGetCount(source)
                var images: [UIImage] = []

                for i in 0..<count {
                    if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                        let image = UIImage(cgImage: cgImage)
                        images.append(image)
                    }
                }

                DispatchQueue.main.async {
                    self.imageView.stopAnimating()
                    self.imageView.animationImages = nil
                    
                    self.imageView.animationImages = images
                    self.imageView.animationDuration = TimeInterval(speed)
                    self.imageView.startAnimating()
                }
            }
        }
    }
    
    // Shares the TimeFrame as a GIF to the user's other apps when the "Share" button is tapped
    @IBAction func onShareTapped(_ sender: Any) {
        var shareItem: Any = ""
        let gifURL = UIImage.animatedGif(from: timeframeImages, from: 2.0/Float(timeframeImages.count), name: timeframeName)
        
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
