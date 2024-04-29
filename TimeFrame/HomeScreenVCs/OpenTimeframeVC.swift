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
    var timeframe: TimeFrame!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        shareButton.layer.cornerRadius = 5
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.imageView.animationImages = nil   // Release the memory from animating images
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timeframe = allTimeframes[timeframeName]
//        print("TimeFrame name: \(timeframe.name)")
//        print("TimeFrame url: \(timeframe.url)")
        imageView.displayGIF(from: timeframe.url, from: timeframe.selectedSpeed)
    }
    
    // Shares the TimeFrame as a GIF to the user's other apps when the "Share" button is tapped
    @IBAction func onShareTapped(_ sender: Any) {
        var shareItem: Any = ""
        if let imageData = try? Data(contentsOf: timeframe.url) {
            shareItem = imageData
        } else {
            shareItem = timeframe.url
        }
        let activityController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}
