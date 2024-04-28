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

//TODO: update with user's new photo

class ViewTimeLapseViewController: UIViewController {
    
    @IBOutlet weak var timeFrameView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    var activeChallenge: Bool!
    var challenge: Challenge!
    var challengeImages: [UIImage]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCustomBackImage()
        
        for challengeImage in challenge.album {
            challengeImages.append(challengeImage.image)
        }
        
        animateImage()
    }
    
    func animateImage() {
        // TODO: fix if there is only one image
        let actualSpeed = Float(5.0)
        let gifDuration = Float(challengeImages.count) / actualSpeed
        // Calculates the duration for each image
        let imageDuration = gifDuration / Float(challengeImages.count)
        timeFrameView.animationDuration = TimeInterval(gifDuration)
        timeFrameView.animationImages = challengeImages
        timeFrameView.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Display initial image as thumbnail.
        timeFrameView.image = self.challenge.album[0].image
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
    
    @IBAction func onShareButtonTapped(_ sender: Any) {
        var shareItem: Any = ""
        let gifURL = UIImage.animatedGif(from: challengeImages, from: 5.0/Float(challengeImages.count), name: challenge.name)
        
        if gifURL != nil {
            shareItem = gifURL!
        } else {
            // Share first photo in array if there is an error generating the GIF
            shareItem = challengeImages[0]
        }
        
        let activityController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}

