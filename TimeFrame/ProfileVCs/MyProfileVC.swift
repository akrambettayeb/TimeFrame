//
//  MyProfileVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/15/24.
//

import UIKit

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

class MyProfileVC: UIViewController, ProfileChanger, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var myProfileImage: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var imageGrid: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var qrCode: UIBarButtonItem!
    
    let imageCellID = "MyImageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        
        // Circular crop for profile picture
        myProfileImage.layer.cornerRadius = myProfileImage.layer.frame.height / 2
        
        imageGrid.dataSource = self
        imageGrid.delegate = self
        imageGrid.isScrollEnabled = false
        imageGrid.reloadData()
        
        if allGridImages.count == 0 {
            fetchPhotos(10)
        }
        populateVisibleImagesArray()
        
        self.setGridSize(imageGrid)
        self.setProfileScrollHeight(scrollView, imageGrid)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        populateVisibleImagesArray()
        
        imageGrid.reloadData()
        self.setGridSize(imageGrid)
        self.setProfileScrollHeight(scrollView, imageGrid)
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
        }
    }

}
