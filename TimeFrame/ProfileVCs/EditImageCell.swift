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

class EditImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var visibleButton: UIButton!
    var coloredImage: UIImage?
    var grayImage: UIImage?
    
    func grayscaleImage(_ image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)
        let grayscale = ciImage!.applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0.0])
        return UIImage(ciImage: grayscale)
    }
    
    @IBAction func visibleButtonPressed(_ sender: UIButton) {
        visibleButton.isSelected = !visibleButton.isSelected
        if visibleButton.isSelected {
            imageView.image = grayImage
        } else {
            imageView.image = coloredImage
        }
    }
}
