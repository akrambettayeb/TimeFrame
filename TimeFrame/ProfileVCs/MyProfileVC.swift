//
//  MyProfileVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 3/15/24.
//
//  Project: TimeFrame
//  EID: kz4696
//  Course: CS371L


import UIKit
import Photos
import FirebaseAuth
import FirebaseDatabase

var visibleAlbums: [String: [AlbumPhoto]] = [:]
var visibleAlbumNames: [String] = []

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
    @IBOutlet weak var countTimeFrameButton: UIButton!
    
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
        populateVisibleAlbums()
        updateCountButton()
        
        self.setGridSize(imageGrid)
        self.setProfileScrollHeight(scrollView, imageGrid)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        countTimeFrameButton.titleLabel?.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Loads user's username and display name from Firebase
        let userId = Auth.auth().currentUser?.uid
        let usersRef = Database.database().reference().child("users")
        usersRef.child(userId!).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let firstName = value?["firstName"] as? String ?? ""
            let lastName = value?["lastName"] as? String ?? ""
            self.displayNameLabel.text = "\(firstName) \(lastName)"
            
            let username = value?["username"] as? String ?? ""
            self.usernameLabel.text = "@\(username)"
        }
        
        let prevCount = visibleAlbums.count
        populateVisibleAlbums()
        if prevCount != visibleAlbums.count {
            imageGrid.reloadData()
            updateCountButton()
            self.setGridSize(imageGrid)
            self.setProfileScrollHeight(scrollView, imageGrid)
        }
        
        print("MY PROFILE VC")
        print("visible albums: \(visibleAlbumNames)")
    }
    
    // Applies button attributes from the Storyboard
    func updateCountButton() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: countTimeFrameButton.titleLabel!.font!,
            .foregroundColor: countTimeFrameButton.currentTitleColor
        ]
        let attributedTitle = NSAttributedString(string: "\(visibleAlbums.count)\nTimeFrames", attributes: attributes)
        countTimeFrameButton.titleLabel?.textAlignment = .center
        countTimeFrameButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func populateVisibleAlbums() {
        visibleAlbumNames = [String]()
        visibleAlbums = [String: [AlbumPhoto]]()
        for albumName in albumNames {
            let album = allAlbums[albumName]!
            if !album.isEmpty {
                if album[0].profileVisible {
                    visibleAlbumNames.append(albumName)
                    visibleAlbums[albumName] = album
                }
            }
        }
    }
    
    // Sets the number of cells in the grid
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleAlbums.count
    }
    
    // Defines content in each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageGrid.dequeueReusableCell(withReuseIdentifier: imageCellID, for: indexPath) as! MyImageCell
        let index = visibleAlbums.count - indexPath.row - 1
        let albumName = visibleAlbumNames[index]
        cell.imageViewCell.image = visibleAlbums[albumName]?[0].image
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
            // remove leading @ from username
            nextVC.prevUsername = String(usernameLabel.text!.dropFirst())
            nextVC.prevPicture = myProfileImage.image
        } else if segue.identifier == "segueToQR",
           let nextVC = segue.destination as? QRProfileVC {
            nextVC.profilePic = myProfileImage.image
            nextVC.username = usernameLabel.text!
        } else if segue.identifier == "segueToViewImage",
           let nextVC = segue.destination as? ViewImageVC {
            if let indexPaths = imageGrid.indexPathsForSelectedItems {
                let index = visibleAlbums.count - indexPaths[0].row - 1
                nextVC.albumName = visibleAlbumNames[index]
//                nextVC.cellImage = visibleAlbums[visibleAlbumName]?[0].image
                imageGrid.deselectItem(at: indexPaths[0], animated: false)
            }
        }
    }

}
