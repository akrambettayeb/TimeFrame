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
    @IBOutlet weak var countTimeFrameButton: UIButton!

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
    var currentUserEmail: String?
    var isFollowing: Bool = false {
        didSet {
            if isViewLoaded {
                DispatchQueue.main.async { [weak self] in
                    self?.followButton.setTitle(self?.isFollowing ?? false ? "Unfollow" : "Follow", for: .normal)
                    self?.checkForMutualFollowing()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        friendsLabel.isHidden = true
        fetchCurrentUserEmail()
        followButton.setTitle("Loading...", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userProfileData != nil {
            updateUIWithProfileData()
            setupFriendshipStatus()
            updateCounts()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupFriendshipStatus()
    }
    
    private func fetchCurrentUserEmail() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        self.currentUserEmail = Auth.auth().currentUser?.email
    }
    
    private func updateUIWithProfileData() {
        guard isViewLoaded else { return }
        if let data = userProfileData {
            fullnameLabel.text = "\(data["firstName"] as? String ?? "") \(data["lastName"] as? String ?? "")"
            usernameLabel.text = data["username"] as? String ?? "Unknown"
        }
    }

    private func setupFriendshipStatus() {
        guard isViewLoaded else { return }
        guard let profileEmail = userProfileData?["email"] as? String,
              let currentUserEmail = currentUserEmail else {
            DispatchQueue.main.async { [weak self] in
                self?.followButton?.setTitle("Follow", for: .normal)
            }
            return
        }
        let safeProfileEmail = profileEmail.replacingOccurrences(of: ".", with: ",")
        let safeCurrentUserEmail = currentUserEmail.replacingOccurrences(of: ".", with: ",")

        ref.child("following").child(safeCurrentUserEmail).child(safeProfileEmail).observeSingleEvent(of: .value) { [weak self] snapshot in
            DispatchQueue.main.async {
                let currentlyFollowing = snapshot.exists()
                self?.isFollowing = currentlyFollowing
                if let followButton = self?.followButton {
                    followButton.setTitle(currentlyFollowing ? "Unfollow" : "Follow", for: .normal)
                }
            }
        }
    }

    private func checkForMutualFollowing() {
        guard let profileEmail = userProfileData?["email"] as? String,
              let currentUserEmail = currentUserEmail else {
            friendsLabel.isHidden = true
            return
        }
        let safeProfileEmail = profileEmail.replacingOccurrences(of: ".", with: ",")
        let safeCurrentUserEmail = currentUserEmail.replacingOccurrences(of: ".", with: ",")
        
        let currentUsersFollowingRef = ref.child("following").child(safeCurrentUserEmail)
        let profileUsersFollowingRef = ref.child("following").child(safeProfileEmail)

        currentUsersFollowingRef.child(safeProfileEmail).observeSingleEvent(of: .value) { [weak self] snapshot in
            let currentUserFollowsProfileUser = snapshot.exists()

            profileUsersFollowingRef.child(safeCurrentUserEmail).observeSingleEvent(of: .value) { [weak self] snapshot in
                let profileUserFollowsCurrentUser = snapshot.exists()
                DispatchQueue.main.async {
                    self?.friendsLabel.isHidden = !(currentUserFollowsProfileUser && profileUserFollowsCurrentUser)
                }
            }
        }
    }

    @IBAction func followButtonTapped(_ sender: UIButton) {
        guard let profileEmail = userProfileData?["email"] as? String,
              let profileUsername = userProfileData?["username"] as? String,
              let currentUserEmail = currentUserEmail else { return }
        let safeProfileEmail = profileEmail.replacingOccurrences(of: ".", with: ",")
        let safeCurrentUserEmail = currentUserEmail.replacingOccurrences(of: ".", with: ",")
        
        let isCurrentlyFollowing = isFollowing

        isFollowing.toggle()

        let followingRef = ref.child("following").child(safeCurrentUserEmail).child(safeProfileEmail)
        let followersRef = ref.child("followers").child(safeProfileEmail).child(safeCurrentUserEmail)
        
        if isCurrentlyFollowing {
            followingRef.removeValue()
            followersRef.removeValue()
            showAlert(title: "Unfollowed", message: "You have unfollowed \(profileUsername).")
        } else {
            followingRef.setValue(true)
            followersRef.setValue(true)
            showAlert(title: "Followed", message: "You are now following \(profileUsername).")
        }
        self.updateCounts()
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
        guard isViewLoaded else { return }
        guard let profileEmail = userProfileData?["email"] as? String else { return }
        let safeProfileEmail = profileEmail.replacingOccurrences(of: ".", with: ",")
        updateProfileCounts(for: safeProfileEmail)
    }

    private func updateProfileCounts(for safeProfileEmail: String) {
        let attributes = countButtonAttributedTitleAttributes()
        
        ref.child("following").child(safeProfileEmail).observeSingleEvent(of: .value) { [weak self] snapshot in
            let count = snapshot.childrenCount
            DispatchQueue.main.async {
                let followingAttributedTitle = NSAttributedString(string: "\(count)\nFollowing", attributes: attributes)
                self?.followingCountButton.setAttributedTitle(followingAttributedTitle, for: .normal)
            }
        }

        ref.child("followers").child(safeProfileEmail).observeSingleEvent(of: .value) { [weak self] snapshot in
            let count = snapshot.childrenCount
            DispatchQueue.main.async {
                let followersAttributedTitle = NSAttributedString(string: "\(count)\nFollowers", attributes: attributes)
                self?.followersCountButton.setAttributedTitle(followersAttributedTitle, for: .normal)
            }
        }

        fetchFriendsList(for: safeProfileEmail) { [weak self] friendsList in
            DispatchQueue.main.async {
                let friendsCount = friendsList.count
                let friendsAttributedTitle = NSAttributedString(string: "\(friendsCount)\nFriends", attributes: attributes)
                self?.friendsCountButton.setAttributedTitle(friendsAttributedTitle, for: .normal)
            }
        }
    }

    private func countButtonAttributedTitleAttributes() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [
            .font: countTimeFrameButton.titleLabel!.font!,
            .foregroundColor: countTimeFrameButton.titleLabel!.textColor,
            .paragraphStyle: paragraphStyle
        ]
    }


    private func fetchFriendsList(for email: String, completion: @escaping ([String]) -> Void) {
        let followingRef = ref.child("following").child(email)
        let followersRef = ref.child("followers").child(email)

        followingRef.observeSingleEvent(of: .value) { (followingSnapshot) in
            followersRef.observeSingleEvent(of: .value) { (followersSnapshot) in
                var followingSet = Set<String>()
                var followersSet = Set<String>()

                if let followingDict = followingSnapshot.value as? [String: Bool] {
                    followingSet = Set(followingDict.keys)
                }

                if let followersDict = followersSnapshot.value as? [String: Bool] {
                    followersSet = Set(followersDict.keys)
                }

                let friendsList = followingSet.intersection(followersSet)
                completion(Array(friendsList))
            }
        }
    }

    private func showListAlert(title: String) {
        guard let profileEmail = userProfileData?["email"] as? String else { return }
        let safeProfileEmail = profileEmail.replacingOccurrences(of: ".", with: ",")
        let alert = UIAlertController(title: title, message: "Loading...", preferredStyle: .actionSheet)
        
        // Fetch and present the user list based on title
        fetchListForAlert(safeEmail: safeProfileEmail, listType: title.lowercased(), completion: { [weak self] users in
            self?.updateAlert(withUsers: users, title: title)
        })
    }

    private func fetchListForAlert(safeEmail: String, listType: String, completion: @escaping ([String]) -> Void) {
        var childPath = listType
        if listType == "friends" {
            fetchFriendsList(for: safeEmail, completion: completion)
            return
        } else if listType == "following" || listType == "followers" {
            childPath = listType
        }

        ref.child(childPath).child(safeEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            var emailsList = [String]()
            if let emailsDict = snapshot.value as? [String: Bool] {
                emailsList = emailsDict.compactMap { $0.key }
            }
            self.fetchUsernamesFromEmails(emailsList, completion: completion)
        }) { error in
            print(error.localizedDescription)
            completion([])
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

    
    private func updateAlert(withUsers users: [String], title: String) {
        let alert = UIAlertController(title: title, message: "Loading...", preferredStyle: .actionSheet)

        for username in users {
            let action = UIAlertAction(title: username, style: .default, handler: nil)
            action.isEnabled = false
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
    
    func resetUI() {
        guard isViewLoaded else { return }
        fullnameLabel.text = "Loading..."
        usernameLabel.text = "Loading..."
        followButton.setTitle("Follow", for: .normal)
        friendsLabel.isHidden = true
        friendsCountButton.setTitle("0 Friends", for: .normal)
        followingCountButton.setTitle("0 Following", for: .normal)
        followersCountButton.setTitle("0 Followers", for: .normal)
        fetchCurrentUserEmail()
        setupFriendshipStatus()
        updateCounts()
    }
}
