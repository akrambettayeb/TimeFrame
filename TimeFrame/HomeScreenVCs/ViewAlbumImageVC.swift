//
//  ViewAlbumImageVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/7/24.
//
//  Project: TimeFrame
//  EID: kz4696
//  Course: CS371L


import UIKit

// Displays selected photo from album in a new screen
class ViewAlbumImageVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    var selectedImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = selectedImage
        imageView.enableZoom()
    }
}
