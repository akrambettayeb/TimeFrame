//
//  PhotoStreamCell.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 4/24/24.
//
// Project: TimeFrame
// EID: mas23586
// Course: CS371L

import UIKit
import FirebaseFirestore
import FirebaseStorage

class PhotoStreamCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoStatsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!
    
    var challenge: Challenge!
    var challengeImage: ChallengeImage!
    var image: UIImage!
    var delegate: UIViewController!
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    @IBAction func onLikeButtonPressed(_ sender: Any) {
        if likeButton.imageView?.image == UIImage(systemName: "heart") {
            // Update challenge image and label likes.
            challengeImage.numLikes += 1
            
            // Format number of views and likes.
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let viewString = numberFormatter.string(from: NSNumber(value: challengeImage.numViews))
            let likeString = numberFormatter.string(from: NSNumber(value: challengeImage.numLikes))
            photoStatsLabel.text = "\(viewString!) views, \(likeString!) likes"
            
            // Update button image.
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            // Update challenge image and label likes.
            challengeImage.numLikes -= 1
            
            // Format number of views and likes.
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let viewString = numberFormatter.string(from: NSNumber(value: challengeImage.numViews))
            let likeString = numberFormatter.string(from: NSNumber(value: challengeImage.numLikes))
            photoStatsLabel.text = "\(viewString!) views, \(likeString!) likes"
            
            // Update button image.
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        updateChallengeImage(challengeImage: challengeImage)
    }
    
    @IBAction func onFlagButtonPressed(_ sender: Any) {
        if flagButton.imageView?.image == UIImage(systemName: "flag") {
            // Update challenge image and label flags.
            challengeImage.numFlags += 1
            
            // Check if we need to hide photo.
            if challengeImage.numFlags >= 10 {
                challengeImage.hidden = true
            }
            
            // Update button image.
            flagButton.setImage(UIImage(systemName: "flag.fill"), for: .normal)
        } else {
            // Update challenge image and label flags.
            challengeImage.numFlags -= 1
            
            // Check if we need to hide photo.
            if challengeImage.numFlags < 10 {
                challengeImage.hidden = false
            }
            
            // Update button image.
            flagButton.setImage(UIImage(systemName: "flag"), for: .normal)
        }
        
        updateChallengeImage(challengeImage: challengeImage)
    }
    
    func updateChallengeImage(challengeImage: ChallengeImage) { db.collection("geochallenges").document(self.challenge.challengeID).collection("album").document(challengeImage.documentID!).setData([:])
        
        let storageRef = storage.reference().child("geochallenges")
        let albumRef = storageRef.child(self.challenge.challengeID + "/" + challengeImage.documentID!)
        
        db.collection("geochallenges").document(self.challenge.challengeID).collection("album").document(challengeImage.documentID!).setData(["url": challengeImage.url, "numViews": challengeImage.numViews, "numLikes": challengeImage.numLikes, "numFlags": challengeImage.numFlags, "hidden": challengeImage.hidden, "capturedTimestamp": Timestamp(date: challengeImage.capturedTimestamp)])
    }
}

