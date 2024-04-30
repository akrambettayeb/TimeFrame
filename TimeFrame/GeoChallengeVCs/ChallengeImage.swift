//
//  ChallengeImage.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 4/23/24.
//
// Project: TimeFrame
// EID: mas23586
// Course: CS371L

import UIKit

class ChallengeImage {
    
    var image: UIImage!
    var url = ""
    var numViews = 1 // 1st view is the user who took photo.
    var numLikes = 0
    var numFlags = 0
    var hidden = false // Hide photo if reaches certain number of flags.
    var capturedTimestamp: Date!
    var documentID: String!
    
    init(image: UIImage, numViews: Int, numLikes: Int, numFlags: Int, hidden: Bool, capturedTimestamp: Date) {
        self.image = image
        self.numViews = numViews
        self.numLikes = numLikes
        self.numFlags = numFlags
        self.hidden = hidden
        self.capturedTimestamp = capturedTimestamp
    }
    
}
