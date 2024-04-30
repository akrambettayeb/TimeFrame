//
//  ActiveChallengeViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 4/24/24.
//
// Project: TimeFrame
// EID: mas23586
// Course: CS371L

import UIKit

class ActiveChallengeViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var previewImage: UIImageView!
    
    var challenge: Challenge!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update labels and image.
        nameLabel.text = challenge.name
        nameLabel.textAlignment = .center
        
        let startString = getDateString(date: challenge.startDate)
        let endString = getDateString(date: challenge.endDate)
        infoLabel.text = "Challenge Status:   Active\nChallenge Dates:    \(startString) - \(endString)"
        infoLabel.textAlignment = .left
        
        // Display initial image as preview.
        previewImage.image = challenge.album[0].image
        
        if (previewImage.image == nil) {
            dismiss(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "activeToViewSegue",
           let destination = segue.destination as? ViewTimeLapseViewController {
            destination.activeChallenge = true
            destination.challenge = self.challenge
        } else if segue.identifier == "activeToAlbumSegue",
                  let destination = segue.destination as? ChallengeAlbumViewController {
            destination.activeChallenge = true
            destination.challenge = self.challenge
        } else if segue.identifier == "activeToAddSegue",
                  let destination = segue.destination as? AddPhotoToChallengeViewController {
            destination.challenge = self.challenge
        }
    }
}
