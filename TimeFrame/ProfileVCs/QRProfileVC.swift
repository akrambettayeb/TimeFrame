//
//  QRProfileVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/17/24.
//
// Project: TimeFrame
// EID: kz4696
// Course: CS371L

import UIKit
import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

class QRProfileVC: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var profilePic: UIImage!
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        profilePicture.image = profilePic
        profilePicture.layer.cornerRadius = profilePicture.layer.frame.height / 2
        if profilePicture.image == UIImage(systemName: "person.crop.circle.fill") &&
            self.traitCollection.userInterfaceStyle == .light {
            profilePicture.layer.borderColor = UIColor(named: "TabBarPurple")?.cgColor
            profilePicture.layer.borderWidth = 3
        }
        backgroundImageView.layer.cornerRadius = 8
        backgroundImageView.layer.masksToBounds = true
        qrImageView.image = generateQRCode("timeframeapp://username=katezhang")
        usernameLabel.text = "@" + username
    }
    
    override func viewWillAppear(_ animated: Bool) {
        qrImageView.image = generateQRCode("timeframeapp://username=katezhang")
    }
    
    func generateQRCode(_ url: String) -> UIImage? {
        let data = Data(url.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        
        guard let qrCodeImage = filter.outputImage else {
            return UIImage(systemName: "xmark")
        }
        
        let transformScale = CGAffineTransform(scaleX: 20.0, y: 20.0)
        let scaledQRImage = qrCodeImage.transformed(by: transformScale)
        
        guard let colorFilter = CIFilter(name: "CIFalseColor") else {
            return UIImage(ciImage: scaledQRImage)
        }
        colorFilter.setValue(scaledQRImage, forKey: "inputImage")
        
        // Transparent background of QR code image
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1, alpha: 0), forKey: "inputColor1")
        
        // Sets QR color white if user is in dark mode, else black
        if self.traitCollection.userInterfaceStyle == .dark {
            colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor0")
        } else {
            colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        }
        guard let coloredImage = colorFilter.outputImage else {
            return UIImage(ciImage: scaledQRImage)
        }
        
        return UIImage(ciImage: coloredImage)
    }

}
