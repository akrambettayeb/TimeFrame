//
//  Challenge.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 4/22/24.
//
// Project: TimeFrame
// EID: mas23586
// Course: CS371L

import UIKit
import MapKit

class Challenge {
    let name: String!
    let coordinate: CLLocationCoordinate2D!
    let startDate: Date!
    let endDate: Date!
    var numViews = 1 // 1st view is challenge creator.
    var numLikes = 0
    var album: [ChallengeImage] = []
    var challengeID: String!
    var loadingDone = false
    
    init(name: String, coordinate: CLLocationCoordinate2D, startDate: Date, endDate: Date, numViews: Int, numLikes: Int, album: [ChallengeImage]) {
        self.name = name
        self.coordinate = coordinate
        self.startDate = startDate
        self.endDate = endDate
        self.numViews = numViews
        self.numLikes = numLikes
        self.album = album
    }
    
    func addChallengeImage(challengeImage: ChallengeImage) {
        self.album.append(challengeImage)
    }
}
