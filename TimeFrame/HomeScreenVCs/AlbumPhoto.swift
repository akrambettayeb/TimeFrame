//
//  AlbumPhoto.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/20/24.
//
//  Project: TimeFrame
//  EID: kz4696
//  Course: CS371L

import UIKit

public class AlbumPhoto {
    var image: UIImage
    var date: String
    var month: String
    var year: String
    var buttonSelected: Bool = false
    
    init(_ image: UIImage) {
        self.image = image
        self.date = ""
        self.month = ""
        self.year = ""
    }
    
    init(_ image: UIImage, _ date: String, _ month: String, _ year: String) {
        self.image = image
        self.date = date
        self.month = month
        self.year = year
    }
}
