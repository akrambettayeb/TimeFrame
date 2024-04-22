//
//  OverlayViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 4/21/24.
//

import UIKit

class OverlayViewController: UIViewController {

    @IBOutlet var overlayView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.alpha = 0.4
    }
}
