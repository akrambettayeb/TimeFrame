//
//  ViewTimeFrameVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/1/24.
//


import UIKit
import UniformTypeIdentifiers

class ViewTimeFrameVC: UIViewController {
    var TimeframeName: String!
    var isPublic: Bool!
    var isFavorite: Bool!
    var isReversed: Bool!
    var selectedDate: String!
    var selectedSpeed: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        self.title = TimeframeName
    }
}

//class ViewTimeFrameVC: UIViewController {
//    
//    @IBOutlet weak var imageView: UIImageView!
//    
//    var headshotImages: [UIImage] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // ERROR here: for some reason fetchedPhotos is empty
//        print("fetched photos: ", fetchedPhotos, "\n\n\n")
//        self.setCustomBackImage()
//        
//        for i in 1...4 {
//            headshotImages.append(UIImage(named: "headshot\(i)")!)
//        }
//        imageView.animationImages = headshotImages.reversed()
//        imageView.animationImages = fetchedPhotos.reversed()
//        imageView.animationDuration = 2.0
//        imageView.startAnimating()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        // Release the memory from animating the images
//        imageView.animationImages = nil
//    }
//    
//    @IBAction func onShareTapped(_ sender: Any) {
//        var shareItem: Any = ""
//        let gifURL = UIImage.animatedGif(from: fetchedPhotos)
//        
//        if gifURL != nil {
//            shareItem = gifURL!
//        } else {
//            shareItem = fetchedPhotos[0]
//        }
//        let activityController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
//        present(activityController, animated: true, completion: nil)
//        // TODO: remove all the URLs?
//    }
//    
//}
