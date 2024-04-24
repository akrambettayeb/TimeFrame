//
//  ViewImageVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/18/24.
//
//  Project: TimeFrame
//  EID: kz4696
//  Course: CS371L


import UIKit

class ViewImageVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var albumName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        self.title = albumName
        var albumPhotos = [UIImage]()
        for photo in allAlbums[albumName]! {
            albumPhotos.append(photo.image)
        }
        if albumPhotos.count > 1 {
            imageView.animationImages = albumPhotos
            imageView.animationDuration = Double(albumPhotos.count) / 4.0
            imageView.startAnimating()
        } else {
            imageView.image = albumPhotos[0]
        }
    }

}
