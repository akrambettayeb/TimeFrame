//
//  ViewTimeLapseViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 3/16/24.
//
// Project: TimeFrame
// EID: mas23586
// Course: CS371L

import UIKit

class ViewTimeLapseViewController: UIViewController {
    
    @IBOutlet weak var timeFrameView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    var activeChallenge: Bool!
    var challenge: Challenge!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCustomBackImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Display initial image as thumbnail.
        timeFrameView.image = self.challenge.album[self.challenge.album.count - 1].image
        locationLabel.text = self.challenge.name
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewToAlbumSegue",
           let destination = segue.destination as? ChallengeAlbumViewController {
            destination.activeChallenge = self.activeChallenge
            destination.challenge = self.challenge
        } else if segue.identifier == "addPhotoSegue",
                  let destination = segue.destination as? AddPhotoToChallengeViewController {
            destination.challenge = self.challenge
        }
    }
    
    @IBAction func onBackButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func onAddPhotoButtonPressed(_ sender: Any) {
        if activeChallenge {
            performSegue(withIdentifier: "addPhotoSegue", sender: self)
        } else {
            let alert = UIAlertController(title: "Cannot add photo", message: "Cannot add photo to inactive challenge.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            present(alert, animated: true)
        }
    }
}

