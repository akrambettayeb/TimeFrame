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

var publicTimeframes: [String: TimeFrame] = [:]
var publicTfNames: [String] = []
public var profilePic: UIImage?

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
    @IBOutlet weak var friendsCountButton: UIButton!
    @IBOutlet weak var followingCountButton: UIButton!
    @IBOutlet weak var followersCountButton: UIButton!
    
    var followersCount: Int = 0
    var followingCount: Int = 0
    var friendsCount: Int = 0
    var currentUserEmail: String?
    
    let imageCellID = "MyImageCell"
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.setCustomBackImage()
        
        myProfileImage.layer.cornerRadius = myProfileImage.layer.frame.height / 2
        if profilePic != nil {
            myProfileImage.image = profilePic
        }
        imageGrid.dataSource = self
        imageGrid.delegate = self
        imageGrid.isScrollEnabled = false
        
        imageGrid.reloadData()
        populatePublicTimeframes()
        updateCountButton()
        
        self.setGridSize(imageGrid)
        self.setProfileScrollHeight(scrollView, imageGrid)
        
        // disable tapping Timeframe count button
        countTimeFrameButton.isUserInteractionEnabled = false
        fetchCurrentUserEmail()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        countTimeFrameButton.titleLabel?.textAlignment = .center
        friendsCountButton.titleLabel?.textAlignment = .center
        followingCountButton.titleLabel?.textAlignment = .center
        followersCountButton.titleLabel?.textAlignment = .center
        super.viewDidAppear(animated)
        updateCountButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrentUserEmail()
        updateProfileCounts()
        
        let prevCount = publicTimeframes.count
        populatePublicTimeframes()
        if prevCount != publicTimeframes.count {
            imageGrid.reloadData()
            updateCountButton()
            self.setGridSize(imageGrid)
            self.setProfileScrollHeight(scrollView, imageGrid)
        }
        
        // Gets user data from Firebase (first and last name, username)
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
    }
    
    // Updates count of friends, followers, following, TimeFrames on the user profile page
    func updateCountButton() {
        let attributes = countButtonAttributedTitleAttributes()
        
        let timeFramesAttributedTitle = NSAttributedString(string: "\(publicTimeframes.count)\nTimeFrames", attributes: attributes)
        countTimeFrameButton.setAttributedTitle(timeFramesAttributedTitle, for: .normal)
        
        let friendsAttributedTitle = NSAttributedString(string: "\(friendsCount)\nFriends", attributes: attributes)
        friendsCountButton.setAttributedTitle(friendsAttributedTitle, for: .normal)
        
        let followingAttributedTitle = NSAttributedString(string: "\(followingCount)\nFollowing", attributes: attributes)
        followingCountButton.setAttributedTitle(followingAttributedTitle, for: .normal)
        
        let followersAttributedTitle = NSAttributedString(string: "\(followersCount)\nFollowers", attributes: attributes)
        followersCountButton.setAttributedTitle(followersAttributedTitle, for: .normal)
    }

    private func countButtonAttributedTitleAttributes() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [
            .font: countTimeFrameButton.titleLabel!.font!,
            .foregroundColor: countTimeFrameButton.currentTitleColor,
            .paragraphStyle: paragraphStyle
        ]
    }
    
    @IBAction func friendsCountButtonTapped(_ sender: Any) {
        showListAlert(title: "Friends")
    }
    
    @IBAction func followersCountButtonTapped(_ sender: Any) {
        showListAlert(title: "Followers")
    }
    
    @IBAction func followingCountButtonTapped(_ sender: Any) {
        showListAlert(title: "Following")
    }
    
    // Show list alert with dynamic data fetching based on title
    private func showListAlert(title: String) {
        guard let email = currentUserEmail else { return }
        let safeEmail = email.replacingOccurrences(of: ".", with: ",")
        let alert = UIAlertController(title: title, message: "Loading...", preferredStyle: .actionSheet)

        if title.lowercased() == "friends" {
            fetchFriendsList(for: safeEmail) { [weak self] friendsList in
                self?.fetchUsernamesFromEmails(friendsList) { usernames in
                    self?.updateAlert(alert, withUsers: usernames, title: title)
                }
            }
        } else {
            let childPath = title.lowercased()
            ref.child(childPath).child(safeEmail).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                var emailsList = [String]()
                if let emailsDict = snapshot.value as? [String: Bool] {
                    emailsList = emailsDict.compactMap { $0.key.replacingOccurrences(of: ",", with: ".") }
                }
                self?.fetchUsernamesFromEmails(emailsList) { usernames in
                    self?.updateAlert(alert, withUsers: usernames, title: title)
                }
            }) { error in
                print(error.localizedDescription)
                alert.message = "An error occurred."
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func fetchUsernamesFromEmails(_ emails: [String], completion: @escaping ([String]) -> Void) {
        var usernames = [String]()
        let group = DispatchGroup()

        for email in emails {
            group.enter()
            // Here you replace the commas back with dots to match the email format in the user nodes.
            let normalizedEmail = email.replacingOccurrences(of: ",", with: ".")
            ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: normalizedEmail).observeSingleEvent(of: .value, with: { snapshot in
                // Since the email is unique, there should be only one child.
                if let user = snapshot.children.allObjects.first as? DataSnapshot,
                   let userDict = user.value as? [String: Any],
                   let username = userDict["username"] as? String {
                    usernames.append(username)
                }
                group.leave()
            })
        }

        group.notify(queue: .main) {
            completion(usernames)
        }
    }


    // Update and present the alert with user list
    private func updateAlert(_ alert: UIAlertController, withUsers users: [String], title: String) {
        DispatchQueue.main.async {
            alert.message = users.isEmpty ? "No \(title) found." : nil
            
            for username in users {
                let action = UIAlertAction(title: username, style: .default, handler: nil)
                action.isEnabled = false
                alert.addAction(action)
            }
            
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }

    // Fetch friends list
    private func fetchFriendsList(for safeEmail: String, completion: @escaping ([String]) -> Void) {
        let followingRef = ref.child("following").child(safeEmail)
        let followersRef = ref.child("followers").child(safeEmail)

        followingRef.observeSingleEvent(of: .value) { (followingSnapshot) in
            if let followingDict = followingSnapshot.value as? [String: Bool] {
                let followingSet = Set(followingDict.keys)
                
                followersRef.observeSingleEvent(of: .value) { (followersSnapshot) in
                    if let followersDict = followersSnapshot.value as? [String: Bool] {
                        let followersSet = Set(followersDict.keys)
                        
                        // Calculate the intersection of both sets to find mutual friends
                        let friendsSet = followingSet.intersection(followersSet)
                        completion(friendsSet.map { $0.replacingOccurrences(of: ",", with: ".") })
                    } else {
                        completion([])
                    }
                }
            } else {
                completion([])
            }
        }
    }
    
    // Iterates through all Timeframes and populates the publicTfNames array with names of only TimeFrames with the private attribute set to false
    func populatePublicTimeframes() {
        publicTfNames = [String]()
        publicTimeframes = [String: TimeFrame]()
        for tfName in timeframeNames {
            let timeframe = allTimeframes[tfName]!
            if !(timeframe.isPrivate) {
                publicTfNames.append(tfName)
                publicTimeframes[tfName] = timeframe
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return publicTimeframes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageGrid.dequeueReusableCell(withReuseIdentifier: imageCellID, for: indexPath) as! MyImageCell
        let tfName = publicTfNames[indexPath.row]
        // Sets image for the cell of the TimeFrame to the thumbnail
        cell.imageViewCell.image = publicTimeframes[tfName]?.thumbnail
        return cell
    }
    
    // Defines layout for the collection view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let collectionWidth = imageGrid.bounds.width
        let cellSize = (collectionWidth - 5) / 3
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        imageGrid.collectionViewLayout = layout
    }
    
    // Defines layout when there is only 1 cell in the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       if collectionView.numberOfItems(inSection: section) == 1 {
           let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
           return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width)
       }
       return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func changeDisplayName(_ displayName: String) {
        displayNameLabel.text = displayName
    }
    
    func changeUsername(_ username: String) {
        usernameLabel.text = username
    }
    
    func changePicture(_ newPicture: UIImage) {
        if myProfileImage != nil {
            myProfileImage.image = newPicture
        }
    }
    
    private func fetchCurrentUserEmail() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        self.currentUserEmail = Auth.auth().currentUser?.email
    }
    
    private func updateProfileCounts() {
        guard let email = currentUserEmail else { return }
        let safeEmail = email.replacingOccurrences(of: ".", with: ",")
        ref.child("followers").child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            self.followersCount = Int(snapshot.childrenCount)
            self.updateCountButton()
        }
        
        ref.child("following").child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            self.followingCount = Int(snapshot.childrenCount)
            self.updateCountButton()
        }
        
        fetchFriendsCount(safeEmail: safeEmail) { count in
            self.friendsCount = count
            self.updateCountButton()
        }
    }

    private func fetchFriendsCount(safeEmail: String, completion: @escaping (Int) -> Void) {
        let followingRef = ref.child("following").child(safeEmail)
        let followersRef = ref.child("followers").child(safeEmail)
        
        followingRef.observeSingleEvent(of: .value) { (followingSnapshot) in
            if let followingDict = followingSnapshot.value as? [String: Bool] {
                let followingSet = Set(followingDict.keys)
                
                followersRef.observeSingleEvent(of: .value) { (followersSnapshot) in
                    if let followersDict = followersSnapshot.value as? [String: Bool] {
                        let followersSet = Set(followersDict.keys)
                        
                        // Calculate the intersection of both sets to find mutual friends
                        let friendsSet = followingSet.intersection(followersSet)
                        completion(friendsSet.count)
                    } else {
                        // Handle the case where the followers data might not be available
                        completion(0)
                    }
                }
            } else {
                // Handle the case where the following data might not be available
                completion(0)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToEditProfile",
           let nextVC = segue.destination as? EditProfileVC {
            nextVC.delegate = self
            nextVC.prevDisplayName = displayNameLabel.text!
            nextVC.prevUsername = String(usernameLabel.text!.dropFirst()) // Remove the '@' from username
            nextVC.prevPicture = myProfileImage.image
        } else if segue.identifier == "segueToQR",
           let nextVC = segue.destination as? QRProfileVC {
            nextVC.profilePic = myProfileImage.image
            nextVC.username = usernameLabel.text!
        } else if segue.identifier == "segueToViewImage",
           let nextVC = segue.destination as? ViewImageVC {
            if let indexPaths = imageGrid.indexPathsForSelectedItems {
                nextVC.tfName = publicTfNames[indexPaths[0].row]
                imageGrid.deselectItem(at: indexPaths[0], animated: false)
            }
        }
    }
}
