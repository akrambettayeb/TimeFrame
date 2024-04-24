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

class PhotoStreamViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var challenge: Challenge!
    let cellID = "photoStreamCell"
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChallengeAlbumCell
        
        // Set image in cell.
        cell.imageView.image = challenge.album[indexPath.row].image
        cell.image = challenge.album[indexPath.row].image
        
        return cell
    }
    
    // Limit collection view to 3 photos per row.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        
        // Calculate width of cells.
        let collectionWidth = collectionView.bounds.width
        let cellSize = (collectionWidth - (5 * 3)) / 3 // 3 rows with 10 distance.
        
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        
        collectionView.collectionViewLayout = layout
    }
}
