//
//  OtherTimeFrameVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/29/24.
//

import UIKit

class OtherTimeFrameVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var thisTimeframe: TimeFrame?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        self.title = thisTimeframe!.name
        imageView.displayGIF(from: thisTimeframe!.url, from: thisTimeframe!.selectedSpeed)
    }

}
