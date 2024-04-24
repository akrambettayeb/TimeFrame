//
//  InactiveChallengeViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 4/24/24.
//
// Project: TimeFrame
// EID: mas23586
// Course: CS371L

import UIKit

class InactiveChallengeViewController: UIViewController {

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
        infoLabel.text = "Challenge Status:   Inactive\nChallenge Dates:    \(startString) - \(endString)"
        infoLabel.textAlignment = .left
        
        // Display initial image as preview.
        previewImage.image = challenge.album[challenge.album.count - 1].image
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "inactiveToViewSegue",
           let destination = segue.destination as? ViewTimeLapseViewController {
            destination.activeChallenge = false
            destination.challenge = self.challenge
        } else if segue.identifier == "inactiveToAlbumSegue",
                  let destination = segue.destination as? ChallengeAlbumViewController {
            destination.activeChallenge = false
            destination.challenge = self.challenge
        }
    }
}
