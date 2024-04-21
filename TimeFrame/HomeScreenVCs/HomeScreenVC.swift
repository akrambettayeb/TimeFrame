//
//  HomeScreenVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/7/24.
//
//  Project: TimeFrame
//  EID: kz4696
//  Course: CS371L


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


public var allAlbums: [String: [AlbumPhoto]] = [:]
public var albumNames: [String] = []
public var allTimeframes: [String: [UIImage]] = [:]
public var timeframeNames: [String] = []

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
        
        // Forces the right arrow image to be to the right of the text
        viewAlbumsButton.semanticContentAttribute = .forceRightToLeft
        viewTimeframesButton.semanticContentAttribute = .forceRightToLeft
        
        albumsCollectionView.delegate = self
        albumsCollectionView.dataSource = self
        timeframesCollectionView.delegate = self
        timeframesCollectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timeframesCollectionView.reloadData()
        albumsCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Layout for album collection view
        let albumLayout = UICollectionViewFlowLayout()
        let albumCollectionWidth = albumsCollectionView.bounds.width
        let albumCollectionHeight = albumsCollectionView.bounds.height
        let albumCellWidth = (albumCollectionWidth - 20) / 3
        let albumCellHeight = (albumCollectionHeight - 10) / 2
        
        albumLayout.itemSize = CGSize(width: albumCellWidth, height: albumCellHeight)
        albumLayout.minimumLineSpacing = 8
        albumLayout.minimumInteritemSpacing = 10
        albumLayout.scrollDirection = .horizontal
        albumsCollectionView.collectionViewLayout = albumLayout
        
        // Layout for timeframe collection view
        let timeLayout = UICollectionViewFlowLayout()
        timeLayout.itemSize = CGSize(width: albumCellWidth, height: albumCellHeight)
        timeLayout.minimumLineSpacing = 8
        timeLayout.minimumInteritemSpacing = 10
        timeLayout.scrollDirection = .horizontal
        timeframesCollectionView.collectionViewLayout = timeLayout
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.albumsCollectionView {
            return allAlbums.count
        } else {
            return allTimeframes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.albumsCollectionView {
            let cell = albumsCollectionView.dequeueReusableCell(withReuseIdentifier: albumCellID, for: indexPath) as! HomeAlbumCell
            let albumName = albumNames[indexPath.row]
            cell.albumNameLabel.text = albumName
            if allAlbums[albumName]!.isEmpty {
                // Sets a default image for empty albums
                cell.imageView.image = UIImage(systemName: "person.crop.rectangle.stack.fill")
            } else {
                cell.imageView.image = allAlbums[albumName]?.last?.image
            }
            return cell
        } else {
            let cell = timeframesCollectionView.dequeueReusableCell(withReuseIdentifier: timeframeCellID, for: indexPath) as! HomeTimeframeCell
            let timeframeName = timeframeNames[indexPath.row]
            cell.timeframeNameLabel.text = timeframeName
            if allTimeframes[timeframeName]!.isEmpty {
                // Will be replaced, sets a default image in case the number of TimeFrame cells is set to the number of albums and there are fewer TimeFrames
                cell.imageView.image = UIImage(systemName: "person.crop.rectangle.stack.fill")
            } else {
                cell.imageView.image = allTimeframes[timeframeName]![indexPath.row]
            }
            return cell
        }
    }
    
    func updateAlbums() {
        if albumsCollectionView != nil {
            albumsCollectionView.reloadData()
        }
    }
    
    func updateTimeframes() {
        if timeframesCollectionView != nil {
            timeframesCollectionView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToAlbumVC",
           let nextVC = segue.destination as? AlbumViewController {
            if let indexPaths = albumsCollectionView.indexPathsForSelectedItems {
                // Passes the album name of the selected album to the AlbumViewController screen
                let index = indexPaths[0].row
                nextVC.albumName = albumNames[index]
                albumsCollectionView.deselectItem(at: indexPaths[0], animated: false)
            }
        } else if segue.identifier == "segueToOpenTimeframeVC",
            let nextVC = segue.destination as? OpenTimeframeVC {
            if let indexPaths = timeframesCollectionView.indexPathsForSelectedItems {
                // Passes the name of the TimeFrame so that it can be displayed in a new screen
                let index = indexPaths[0].row
                nextVC.timeframeName = timeframeNames[index]
                timeframesCollectionView.deselectItem(at: indexPaths[0], animated: false)
            }
        }
    }
    
    @IBAction func unwindFromViewTimeframeVC(_ segue: UIStoryboardSegue) {
        // Left empty, triggered from save button in ViewTimeframeVC
    }
}
