//
//  MyProfileVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/15/24.
//
// Project: TimeFrame
// EID: kz4696
// Course: CS371L

import UIKit
import Photos

var allGridImages: [ProfileGridImage] = []
var visibleGridImages: [ProfileGridImage] = []

protocol ProfileChanger {
    func changeDisplayName(_ displayName: String)
    func changeUsername(_ username: String)
    func changePicture(_ newPicture: UIImage)
}

class MyImageCell: UICollectionViewCell {
    @IBOutlet weak var imageViewCell: UIImageView!
}

class MyProfileVC: UIViewController, ProfileChanger, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver {
    
    @IBOutlet weak var myProfileImage: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var imageGrid: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var qrCode: UIBarButtonItem!
    @IBOutlet weak var countTimeFrameButton: UIButton!
    
    let imageCellID = "MyImageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        PHPhotoLibrary.shared().register(self)
        
        // Circular crop for profile picture
        myProfileImage.layer.cornerRadius = myProfileImage.layer.frame.height / 2
        
        imageGrid.dataSource = self
        imageGrid.delegate = self
        imageGrid.isScrollEnabled = false
        
        if allGridImages.count == 0 {
            fetchPhotos(10)
        }
        imageGrid.reloadData()
        populateVisibleImagesArray()
        updateCountButton()
        
        self.setGridSize(imageGrid)
        self.setProfileScrollHeight(scrollView, imageGrid)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        countTimeFrameButton.titleLabel?.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateVisibleImagesArray()
        imageGrid.reloadData()
        updateCountButton()
        self.setGridSize(imageGrid)
        self.setProfileScrollHeight(scrollView, imageGrid)
    }
    
    // Applies button attributes from the Storyboard
    func updateCountButton() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: countTimeFrameButton.titleLabel!.font!,
            .foregroundColor: countTimeFrameButton.currentTitleColor
        ]
        let attributedTitle = NSAttributedString(string: "\(visibleGridImages.count)\nTimeFrames", attributes: attributes)
        countTimeFrameButton.titleLabel?.textAlignment = .center
        countTimeFrameButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func populateVisibleImagesArray() {
        visibleGridImages = []
        for item in allGridImages {
            if item.visible {
                visibleGridImages.append(item)
            }
        }
    }
    
    // Sets the number of cells in the grid
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleGridImages.count
    }
    
    // Defines content in each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageGrid.dequeueReusableCell(withReuseIdentifier: imageCellID, for: indexPath) as! MyImageCell
        let row = indexPath.row
        let count = visibleGridImages.count
        cell.imageViewCell.image = visibleGridImages[count - row - 1].image
        return cell
    }
    
    // Sets minimum spacing between cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    // Sets cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numCells = 3.0
        let viewWidth = collectionView.bounds.width - (numCells - 1) * 2.0
        let cellSize = viewWidth / numCells - 0.01
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func changeDisplayName(_ displayName: String) {
        displayNameLabel.text = displayName
    }
    
    func changeUsername(_ username: String) {
        usernameLabel.text = username
    }
    
    func changePicture(_ newPicture: UIImage) {
        myProfileImage.image = newPicture
    }
    
    // Passes profile data to Edit Profile screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToEditProfile",
           let nextVC = segue.destination as? EditProfileVC {
            nextVC.delegate = self
            nextVC.prevDisplayName = displayNameLabel.text!
            nextVC.prevUsername = usernameLabel.text!
            nextVC.prevPicture = myProfileImage.image
        } else if segue.identifier == "segueToQR",
           let nextVC = segue.destination as? QRProfileVC {
            nextVC.profilePic = myProfileImage.image
            nextVC.username = usernameLabel.text!
        } else if segue.identifier == "segueToViewImage",
           let nextVC = segue.destination as? ViewImageVC {
            if let indexPaths = imageGrid.indexPathsForSelectedItems {
                let gridIndex = visibleGridImages.count - indexPaths[0].row - 1
                nextVC.cellImage = visibleGridImages[gridIndex].image
                imageGrid.deselectItem(at: indexPaths[0], animated: false)
            }
        }
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // TODO: implement, this should replace the first k elements of the allGridImages array
    }
    
    // Unregister as a photo library change observer
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

}
