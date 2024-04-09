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

class ViewAlbumImageVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    var selectedImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = selectedImage
        imageView.enableZoom()
    }
}
