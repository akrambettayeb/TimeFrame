//
//  ViewTimeFrameVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/1/24.
//


// TODO: Add comments!!

// TODO: Add async threads to make things less laggy

import UIKit
import UniformTypeIdentifiers

extension UIImage {
    static func animatedGif(from images: [UIImage]) -> URL? {
        let fileProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]  as CFDictionary
        let frameProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFDelayTime as String): 1.0]] as CFDictionary
        
        let documentsDirectoryURL: URL? = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL: URL? = documentsDirectoryURL?.appendingPathComponent("animated.gif")
        
        if let url = fileURL as CFURL? {
            if let destination = CGImageDestinationCreateWithURL(url, UTType.gif.identifier as CFString, images.count, nil) {
                CGImageDestinationSetProperties(destination, fileProperties)
                for image in images {
                    if let cgImage = image.cgImage {
                        CGImageDestinationAddImage(destination, cgImage, frameProperties)
                    }
                }
                if !CGImageDestinationFinalize(destination) {
                    print("Failed to finalize the image destination")
                }
                print("Url = \(fileURL!)")
                return fileURL
            }
        }
        return nil
    }
}

class ViewTimeFrameVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var headshotImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1...4 {
            headshotImages.append(UIImage(named: "headshot\(i)")!)
        }
        imageView.animationImages = headshotImages.reversed()
        imageView.animationDuration = 2.0
        imageView.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Release the memory from animating the images
        imageView.animationImages = nil
    }
    
    @IBAction func onShareTapped(_ sender: Any) {
        var shareItem: Any = ""
        let gifURL = UIImage.animatedGif(from: headshotImages)
        
        if gifURL != nil {
            shareItem = gifURL!
        } else {
            shareItem = headshotImages[0]
        }
        let activityController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        // TODO: remove all the URLs?
    }
    
}
