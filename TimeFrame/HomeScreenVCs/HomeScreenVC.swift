//
//  HomeScreenVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/7/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeAlbumCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
}

class HomeTimeframeCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeframeNameLabel: UILabel!
}


protocol ImageLoader {
    func updateAlbums()
    func updateTimeframes()
}


public var allAlbums: [String: [UIImage]] = [:]
public var albumNames: [String] = []

class HomeScreenVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ImageLoader {
    
    var delegate: UIViewController!
    
    @IBOutlet weak var viewAlbumsButton: UIButton!
    @IBOutlet weak var viewTimeframesButton: UIButton!
    
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    @IBOutlet weak var timeframesCollectionView: UICollectionView!
    
    let albumCellID = "HomeAlbumCell"
    let timeframeCellID = "HomeTimeframeCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        viewAlbumsButton.semanticContentAttribute = .forceRightToLeft
        viewTimeframesButton.semanticContentAttribute = .forceRightToLeft
        
        albumsCollectionView.delegate = self
        albumsCollectionView.dataSource = self
        timeframesCollectionView.delegate = self
        timeframesCollectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        albumsCollectionView.reloadData()
        timeframesCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Same layout for collection view of albums and Timeframes
        let layout = UICollectionViewFlowLayout()
        let collectionWidth = albumsCollectionView.bounds.width
        let collectionHeight = albumsCollectionView.bounds.height
        let cellWidth = (collectionWidth - 20) / 3
        let cellHeight = (collectionHeight - 10) / 2
        
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        
        albumsCollectionView.collectionViewLayout = layout
        timeframesCollectionView.collectionViewLayout = layout
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.albumsCollectionView {
            return allAlbums.count
        } else { // TODO: timeframe stuff
            return allAlbums.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.albumsCollectionView {
            let cell = albumsCollectionView.dequeueReusableCell(withReuseIdentifier: albumCellID, for: indexPath) as! HomeAlbumCell
            let albumName = albumNames[indexPath.row]
            cell.albumNameLabel.text = albumName
            if allAlbums[albumName]!.isEmpty {
                cell.imageView.image = UIImage(systemName: "person.crop.rectangle.stack.fill")
            } else {
                cell.imageView.image = allAlbums[albumName]![0]
            }
            return cell
        } else {    // TODO: account for timeframe
            let cell = timeframesCollectionView.dequeueReusableCell(withReuseIdentifier: timeframeCellID, for: indexPath) as! HomeTimeframeCell
            let timeframeName = albumNames[indexPath.row]
            cell.timeframeNameLabel.text = timeframeName
            if allAlbums[timeframeName]!.isEmpty {
                cell.imageView.image = UIImage(systemName: "person.crop.rectangle.stack.fill")
            } else {
                cell.imageView.image = allAlbums[timeframeName]![0]
            }
            return cell
        }
    }
    
    func updateAlbums() {
        albumsCollectionView.reloadData()
    }
    
    func updateTimeframes() {
        timeframesCollectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToAlbumVC",
           let nextVC = segue.destination as? AlbumViewController {
            if let indexPaths = albumsCollectionView.indexPathsForSelectedItems {
                let index = indexPaths[0].row
                nextVC.albumName = albumNames[index]
                albumsCollectionView.deselectItem(at: indexPaths[0], animated: false)
            }
        }
    }
}
