//
//  ViewImageVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/18/24.
//

import UIKit

class ViewImageVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var cellImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        imageView.image = cellImage
    }

}
