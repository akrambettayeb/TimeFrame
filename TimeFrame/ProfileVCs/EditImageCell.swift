//
//  EditImageCell.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/16/24.
//
//  Project: TimeFrame
//  EID: kz4696
//  Course: CS371L


import UIKit

// Defines cell in the EditProfile view controller collection view
class EditImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var visibleButton: UIButton!
    var coloredImage: UIImage?
    var grayImage: UIImage?
    
    // Applies grayscale filter to image and preserves original orientation
    func grayscaleImage(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else {
            return nil
        }
        
        let context = CIContext(options: nil)
        
        guard let grayscaleFilter = CIFilter(name: "CIColorControls") else {
            return nil
        }
        
        grayscaleFilter.setValue(ciImage, forKey: kCIInputImageKey)
        grayscaleFilter.setValue(0.0, forKey: kCIInputSaturationKey)
        
        guard let outputImage = grayscaleFilter.outputImage else {
            return nil
        }
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        } else {
            return nil
        }
    }
    
    @IBAction func visibleButtonPressed(_ sender: UIButton) {
        visibleButton.isSelected = !visibleButton.isSelected
        if visibleButton.isSelected {
            imageView.image = coloredImage
        } else {
            imageView.image = grayImage
        }
    }
}
