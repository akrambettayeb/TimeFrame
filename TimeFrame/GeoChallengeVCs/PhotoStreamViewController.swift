//
//  PhotoStreamViewController.swift
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

class PhotoStreamViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var challenge: Challenge!
    let cellID = "photoStreamCell"
    var selectedImageIndex: Int!
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self

        setCustomBackImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update collection view data.
        collectionView.reloadData()
    }
    
    @IBAction func onBackButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // Return the number of photos in app album.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return challenge.album.count
    }
    
    // Create album cell.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // TODO: update number of views
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotoStreamCell
        
        // Set image in cell.
        cell.imageView.image = challenge.album[indexPath.row].image
        cell.image = challenge.album[indexPath.row].image
        cell.challenge = challenge
        cell.challengeImage = challenge.album[indexPath.row]
        
        // Update view count.
        cell.challengeImage.numViews += 1
        updateChallengeImage(challengeImage: cell.challengeImage)
        
        // Format number of views and likes.
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let viewString = numberFormatter.string(from: NSNumber(value: cell.challengeImage.numViews))
        let likeString = numberFormatter.string(from: NSNumber(value: cell.challengeImage.numLikes))
        cell.photoStatsLabel.text = "\(viewString!) views, \(likeString!) likes"
        
        // Format date captured.
        cell.dateLabel.text = getDateString(date: cell.challengeImage.capturedTimestamp)
        cell.delegate = self
        
        return cell
    }
    
    // Limit collection view to 3 photos per row.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let collectionWidth = collectionView.bounds.width
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: collectionWidth, height: 540)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
        
        // Initially scroll to selected image in challenge.
        collectionView.scrollToItem(at: IndexPath(row: selectedImageIndex!, section: 0), at: .top, animated: true)
    }
    
    func updateChallengeImage(challengeImage: ChallengeImage) { db.collection("geochallenges").document(self.challenge.challengeID).collection("album").document(challengeImage.documentID!).setData([:])
        
        let storageRef = storage.reference().child("geochallenges")
        let albumRef = storageRef.child(self.challenge.challengeID + "/" + challengeImage.documentID!)
        
        db.collection("geochallenges").document(self.challenge.challengeID).collection("album").document(challengeImage.documentID!).setData(["url": challengeImage.url, "numViews": challengeImage.numViews, "numLikes": challengeImage.numLikes, "numFlags": challengeImage.numFlags, "hidden": challengeImage.hidden, "capturedTimestamp": Timestamp(date: challengeImage.capturedTimestamp)])
    }
}
