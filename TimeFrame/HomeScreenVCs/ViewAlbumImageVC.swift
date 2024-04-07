//
//  ViewAlbumImageVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/7/24.
//

import UIKit

class ViewAlbumImageVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var selectedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = selectedImage
    }
}
