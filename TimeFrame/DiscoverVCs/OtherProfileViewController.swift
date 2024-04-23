//
//  OtherProfileViewController.swift
//  TimeFrame
//
//  Created by Akram Bettayeb on 4/22/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class OtherProfileViewController: UIViewController {
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var friendsLabel: UILabel!
    
    @IBOutlet weak var friendsCountButton: UIButton!
    @IBOutlet weak var followingCountButton: UIButton!
    @IBOutlet weak var followersCountButton: UIButton!
    
    var ref: DatabaseReference!
    var userProfileData: [String: Any]? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.updateUIWithProfileData()
                self?.setupFriendshipStatus()
                self?.updateCounts()
            }
        }
    }
    var currentUserUsername: String?
    var isFollowing: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.followButton.setTitle(strongSelf.isFollowing ? "Unfollow" : "Follow", for: .normal)
                strongSelf.checkForMutualFollowing()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        friendsLabel.isHidden = true
        fetchCurrentUserUsername()
    }
    
    private func fetchCurrentUserUsername() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        ref.child("users").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            self?.currentUserUsername = (snapshot.value as? NSDictionary)?["username"] as? String ?? ""
        }
    }
    
    private func updateUIWithProfileData() {
        if let data = userProfileData {
            fullnameLabel.text = "\(data["firstName"] as? String ?? "") \(data["lastName"] as? String ?? "")"
            usernameLabel.text = data["username"] as? String
        }
    }
    
    private func setupFriendshipStatus() {
        guard let profileUsername = userProfileData?["username"] as? String, let currentUsername = currentUserUsername else { return }
        ref.child("following").child(currentUsername).child(profileUsername).observeSingleEvent(of: .value) { [weak self] snapshot in
            self?.isFollowing = snapshot.exists()
        }
    }
    
    private func checkForMutualFollowing() {
        guard let profileUsername = userProfileData?["username"] as? String, let currentUserUsername = currentUserUsername else {
            friendsLabel.isHidden = true
            return
        }
        let currentUsersFollowingRef = ref.child("following").child(currentUserUsername)
        let profileUsersFollowingRef = ref.child("following").child(profileUsername)

        currentUsersFollowingRef.child(profileUsername).observeSingleEvent(of: .value) { [weak self] snapshot in
            let currentUserFollowsProfileUser = snapshot.exists()

            profileUsersFollowingRef.child(currentUserUsername).observeSingleEvent(of: .value) { [weak self] snapshot in
                let profileUserFollowsCurrentUser = snapshot.exists()
                DispatchQueue.main.async {
                    self?.friendsLabel.isHidden = !(currentUserFollowsProfileUser && profileUserFollowsCurrentUser)
                }
            }
        }
    }

    @IBAction func followButtonTapped(_ sender: UIButton) {
        guard let profileUsername = userProfileData?["username"] as? String, let currentUsername = currentUserUsername else { return }
        let isCurrentlyFollowing = isFollowing

        isFollowing.toggle()

        let followingRef = ref.child("following").child(currentUsername).child(profileUsername)
        let followersRef = ref.child("followers").child(profileUsername).child(currentUsername)
        
        if isCurrentlyFollowing {
            followingRef.removeValue()
            followersRef.removeValue()
            showAlert(title: "Unfollowed", message: "You have unfollowed \(profileUsername).")
        } else {
            followingRef.setValue(true)
            followersRef.setValue(true)
            showAlert(title: "Followed", message: "You are now following \(profileUsername).")
        }
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
    
    private func updateCounts() {
        guard let profileUsername = userProfileData?["username"] as? String else { return }
        
        // Define the paragraph style for middle justification and font attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont(name: "Helvetica", size: 15) ?? UIFont.systemFont(ofSize: 15)
        ]
        
        ref.child("following").child(profileUsername).observeSingleEvent(of: .value) { [weak self] snapshot in
            let count = snapshot.childrenCount
            DispatchQueue.main.async {
                // Create an attributed string with paragraph style for the button
                let followingAttributedTitle = NSAttributedString(
                    string: "\(count)\nFollowing",
                    attributes: attributes
                )
                self?.followingCountButton.setAttributedTitle(followingAttributedTitle, for: .normal)
            }
        }

        ref.child("followers").child(profileUsername).observeSingleEvent(of: .value) { [weak self] snapshot in
            let count = snapshot.childrenCount
            DispatchQueue.main.async {
                let followersAttributedTitle = NSAttributedString(
                    string: "\(count)\nFollowers",
                    attributes: attributes
                )
                self?.followersCountButton.setAttributedTitle(followersAttributedTitle, for: .normal)
            }
        }

        fetchFriendsList(for: profileUsername) { [weak self] friendsList in
            DispatchQueue.main.async {
                let friendsCount = friendsList.count
                let titleText = friendsCount == 0 ? "0\nFriends" : "\(friendsCount)\nFriends"
                let friendsAttributedTitle = NSAttributedString(
                    string: titleText,
                    attributes: attributes
                )
                self?.friendsCountButton.setAttributedTitle(friendsAttributedTitle, for: .normal)
            }
        }
    }



    private func fetchFriendsList(for username: String, completion: @escaping ([String]) -> Void) {
        let followingRef = ref.child("following").child(username)
        let followersRef = ref.child("followers").child(username)

        followingRef.observeSingleEvent(of: .value) { (followingSnapshot) in
            followersRef.observeSingleEvent(of: .value) { (followersSnapshot) in
                // Initialize empty sets
                var followingSet = Set<String>()
                var followersSet = Set<String>()

                // Safely attempt to extract following users
                if let followingDict = followingSnapshot.value as? [String: Bool] {
                    followingSet = Set(followingDict.keys)
                }

                // Safely attempt to extract followers
                if let followersDict = followersSnapshot.value as? [String: Bool] {
                    followersSet = Set(followersDict.keys)
                }

                // Calculate the intersection of both sets to find mutual friends
                let friendsList = followingSet.intersection(followersSet)
                // Complete with the array of mutual friends
                completion(Array(friendsList))
            }
        }
    }

    private func showListAlert(title: String) {
        guard let profileUsername = userProfileData?["username"] as? String else { return }

        let alert = UIAlertController(title: title, message: "Loading...", preferredStyle: .actionSheet)
        
        if title.lowercased() == "friends" {
            fetchFriendsList(for: profileUsername) { [weak self] friendsList in
                self?.updateAlert(withUsers: friendsList, title: title)
            }
        } else {
            let childPath = title.lowercased() == "following" ? "following" : "followers"
            ref.child(childPath).child(profileUsername).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                var usersList = [String]()
                if let userDict = snapshot.value as? [String: Bool] {
                    usersList = userDict.compactMap { $0.key }
                }
                self?.updateAlert(withUsers: usersList, title: title)
            }) { error in
                print(error.localizedDescription)
                alert.message = "An error occurred."
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func updateAlert(withUsers users: [String], title: String) {
        let alert = UIAlertController(title: title, message: "Loading...", preferredStyle: .actionSheet)

        for username in users {
            let action = UIAlertAction(title: username, style: .default, handler: nil)
              action.isEnabled = false  // This makes the action non-tappable
              alert.addAction(action)
        }

        if users.isEmpty {
            alert.message = "No \(title) found."
        } else {
            alert.message = nil
        }

        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
