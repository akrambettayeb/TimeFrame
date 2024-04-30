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
import FirebaseFirestore
import FirebaseStorage

class ViewTimeLapseViewController: UIViewController {
    
    @IBOutlet weak var timeFrameView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeframeStatsLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    var activeChallenge: Bool!
    var challenge: Challenge!
    var challengeImages: [UIImage]! = []
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCustomBackImage()
    }
    
    func animateImage() {
        var animationImages: [UIImage] = []
        for challengeImage in challengeImages {
            animationImages.append(challengeImage.fixOrientation())
        }

        let actualSpeed = Float(5.0)
        let gifDuration = Float(animationImages.count) / actualSpeed
        // Calculates the duration for each image
        let imageDuration = gifDuration / Float(animationImages.count)
        timeFrameView.animationDuration = TimeInterval(gifDuration)
        timeFrameView.animationImages = animationImages
        timeFrameView.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Display initial image as thumbnail.
        timeFrameView.image = self.challenge.album[0].image
        locationLabel.text = self.challenge.name
        
        // Update number of views.
        challenge.numViews += 1
        updateChallenge()
        
        // Format number of views and likes.
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let viewString = numberFormatter.string(from: NSNumber(value: challenge.numViews))
        let likeString = numberFormatter.string(from: NSNumber(value: challenge.numLikes))
        timeframeStatsLabel.text = "\(viewString!) views, \(likeString!) likes"
        
        // Animate image.
        for challengeImage in challenge.album {
            if challengeImage.image != nil {
                challengeImages.append(challengeImage.image)
            }
        }
        
        if challengeImages.count > 0 {
            animateImage()
        }
    }
    
    func updateChallenge() {
        db.collection("geochallenges").document(self.challenge.challengeID).setData(["name": challenge.name!,
            "coordinate": GeoPoint(latitude: challenge.coordinate.latitude, longitude: challenge.coordinate.longitude),
            "startDate": Timestamp(date: challenge.startDate),
            "endDate": Timestamp(date: challenge.endDate),
            "numViews": challenge.numViews,
            "numLikes": challenge.numLikes])
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
    
    @IBAction func onLikeButtonPressed(_ sender: Any) {
        if likeButton.imageView?.image == UIImage(systemName: "heart") {
            // Update challenge image and label likes.
            challenge.numLikes += 1
            
            // Format number of views and likes.
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let viewString = numberFormatter.string(from: NSNumber(value: challenge.numViews))
            let likeString = numberFormatter.string(from: NSNumber(value: challenge.numLikes))
            timeframeStatsLabel.text = "\(viewString!) views, \(likeString!) likes"
            
            // Update button image.
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            // Update challenge image and label likes.
            challenge.numLikes -= 1
            
            // Format number of views and likes.
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let viewString = numberFormatter.string(from: NSNumber(value: challenge.numViews))
            let likeString = numberFormatter.string(from: NSNumber(value: challenge.numLikes))
            timeframeStatsLabel.text = "\(viewString!) views, \(likeString!) likes"
            
            // Update button image.
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        updateChallenge()
    }
}

