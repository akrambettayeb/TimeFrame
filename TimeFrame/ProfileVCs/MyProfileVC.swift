//
//  MyProfileVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/15/24.
//

import UIKit

protocol ProfileChanger {
    func changeDisplayName(_ displayName: String)
    func changeUsername(_ username: String)
    func changePicture(_ newPicture: UIImage)
    func changeCellImage(_ newImage: UIImage)
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
    @IBOutlet weak var qrCode: UIButton!
    
    let imageCellID = "ImageCell"
    var cellImage = UIImage(systemName: "person.crop.circle.fill")
    var cellTint = UIColor(named: "TabBarPurple")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Circular crop for profile picture
        myProfileImage.layer.cornerRadius = myProfileImage.layer.frame.height / 2
        
        imageGrid.dataSource = self
        imageGrid.delegate = self
        imageGrid.isScrollEnabled = false
        imageGrid.reloadData()
        
        // Expands height of the image grid based on content size
        if let flowLayout = imageGrid.collectionViewLayout as? UICollectionViewFlowLayout {
            let contentSize = flowLayout.collectionViewContentSize
            imageGrid.frame.size = CGSize(width: contentSize.width, height: contentSize.height)
            imageGrid.layoutIfNeeded()
        }
        
        // Expands height of the scroll view based on content size
        let distToVC = imageGrid.convert(imageGrid.bounds, to: view)
        let distToTop = distToVC.origin.y
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: distToTop + imageGrid.frame.height + (self.tabBarController?.tabBar.frame.height)!)
        scrollView.showsVerticalScrollIndicator = false
        
        if self.traitCollection.userInterfaceStyle == .dark {
            // do something
        }
    }
    
    // Sets the number of cells in the grid
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    // Defines content in each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageGrid.dequeueReusableCell(withReuseIdentifier: imageCellID, for: indexPath) as! MyImageCell
        cell.imageViewCell.image = cellImage
        cell.imageViewCell.tintColor = cellTint
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
    
    func changeCellImage(_ newImage: UIImage) {
        cellImage = newImage
        cellTint = nil
        imageGrid.reloadData()
    }
    
    // Passes profile data to Edit Profile screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditProfileSegue",
           let nextVC = segue.destination as? EditProfileVC {
            nextVC.delegate = self
            nextVC.prevDisplayName = displayNameLabel.text!
            nextVC.prevUsername = usernameLabel.text!
            nextVC.prevPicture = myProfileImage.image
        }
    }

}
