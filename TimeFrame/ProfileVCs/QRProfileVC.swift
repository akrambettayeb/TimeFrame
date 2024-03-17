//
//  QRProfileVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/17/24.
//

import UIKit
import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

class QRProfileVC: UIViewController {

    @IBOutlet weak var qrImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        let qrCode = generateQRCode("timeframeapp://username=katezhang")
        qrImageView.image = qrCode
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
        return UIImage(ciImage: scaledQRImage)
    }

}
