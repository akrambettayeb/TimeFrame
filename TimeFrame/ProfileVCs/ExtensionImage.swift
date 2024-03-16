//
//  ExtensionImage.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/16/24.
//

import UIKit

extension UIImage {
    
    func grayscaleImage(_ imageView: UIImageView) {
        let ciImage = CIImage(image: imageView.image!)
        let grayscale = ciImage!.applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0.0])
        imageView.image = UIImage(ciImage: grayscale)
    }
}
