//
//  TimeFrame.swift
//  TimeFrame
//
//  Created by Brandon Ling on 4/23/24.
//

import UIKit

public class TimeFrame {
    let url: URL
    let thumbnail: UIImage
    let name: String
    var isPrivate: Bool = false
    var isFavorited: Bool = false
    var selectedSpeed: Float!
    
    init(_ url: URL, _ thumbnail: UIImage, _ name: String, _ isPrivate: Bool, _ isFavorited: Bool, _ selectedSpeed: Float) {
        self.url = url
        self.thumbnail = thumbnail
        self.name = name
        self.isPrivate = isPrivate
        self.isFavorited = isFavorited
        self.selectedSpeed = selectedSpeed
    }
}
