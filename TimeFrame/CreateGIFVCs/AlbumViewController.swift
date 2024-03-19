//
//  AlbumViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 3/18/24.
//

import UIKit
import Photos

class AlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    @IBOutlet weak var albumView: UICollectionView!
    var imageArray = [UIImage]() // Stores images for album.

    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumView.delegate = self
        albumView.dataSource = self

        setCustomBackImage()
        grabPhotos()
    }
    
    // Manages which photos we pull from our Photos.
    func grabPhotos() {
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat // What you want to prioritize when getting images.
        
        // Sets how you want to store photos in album.
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if fetchResult.count > 0 {
            // User has photos to display in the album.
            for i in 0 ..< fetchResult.count {
                // Convert asset to image and add to image array.
                imgManager.requestImage(for: fetchResult.object(at: i), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions, resultHandler: {
                    image, error in
                    self.imageArray.append(image!)
                })
            }
        } else {
            // TODO: Need to show screen for empty album and adding photos to empty album.
            print("User has no photos.")
            self.albumView.reloadData()
        }
        print(self.imageArray)
    }
    
    // Number of cells in album.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = imageArray[indexPath.row]
        return cell
    }
    
    // Set size of photo frame.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numCells = 3.0
        let viewWidth = collectionView.bounds.width - (numCells - 1) * 2.0
        let cellSize = viewWidth / numCells - 0.01
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
}
