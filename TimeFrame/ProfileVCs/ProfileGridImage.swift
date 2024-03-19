//
//  ProfileGridImage.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/17/24.
//
// Project: TimeFrame
// EID: kz4696
// Course: CS371L

import Foundation
import UIKit

public class ProfileGridImage {
    var image: UIImage
    var visible: Bool
    
    // TODO: after initial testing, set all images to private by default
    init(_ image: UIImage) {
        self.image = image
        self.visible = true
    }
    
    init(_ image: UIImage, _ visible: Bool) {
        self.image = image
        self.visible = visible
    }
    
    func show() -> String {
        return """
        \(self.image), visible = \(self.visible)
        """
    }
}
