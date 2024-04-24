//
//  DiscoverSearchViewController.swift
//  TimeFrame
//
//  Created by Akram Bettayeb on 4/22/24.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class DiscoverSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var users: [String] = [] // This will hold usernames for display in the table view
    var userIds: [String: String] = [:] // This will map usernames to user IDs
    var allUsers: [String] = [] // This will hold all usernames for searching
    var ref: DatabaseReference!
    var currentUserUsername: String? // The username of the currently logged-in user

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        ref = Database.database().reference()
        fetchCurrentUserUsername() // Fetch the current user's username
        loadAllUsers()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserSearchTableViewCell", for: indexPath) as? UserSearchTableViewCell else {
            return UITableViewCell()
        }
        cell.usernameLabel.text = users[indexPath.row]
        return cell
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            users = allUsers
        } else {
            searchUsers(searchText: searchText)
        }
        tableView.reloadData()
    }

    private func fetchCurrentUserUsername() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        ref.child("users").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            self?.currentUserUsername = (snapshot.value as? NSDictionary)?["username"] as? String ?? ""
            self?.loadAllUsers() // Re-load all users once the current username is fetched
        }
    }
    
    private func loadAllUsers() {
            ref.child("users").observeSingleEvent(of: .value) { snapshot in
                var loadedUsers: [String] = []
                self.userIds.removeAll()
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot,
                       let dict = snap.value as? [String: Any],
                       let username = dict["username"] as? String {
                        if username != self.currentUserUsername {
                            loadedUsers.append(username)
                        }
                        self.userIds[username] = snap.key // Store the mapping of usernames to their user IDs
                    }
                }
                self.allUsers = loadedUsers
                self.users = loadedUsers.filter { $0 != self.currentUserUsername }
                self.tableView.reloadData()
            }
        }

    private func searchUsers(searchText: String) {
        let lowercasedSearchText = searchText.lowercased()
        users = allUsers.filter { $0.lowercased().contains(lowercasedSearchText) }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let username = users[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        if let userId = userIds[username] {
            loadUserProfileData(userId: userId)
        }
    }

    private func loadUserProfileData(userId: String) {
        ref.child("users").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            if let userProfile = snapshot.value as? [String: Any] {
                self?.performSegue(withIdentifier: "toOtherProfile", sender: userProfile)
            } else {
                self?.showAlert(message: "Failed to load user profile.")
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toOtherProfile",
           let userProfile = sender as? [String: Any],
           let otherVC = segue.destination as? OtherProfileViewController {
            otherVC.userProfileData = userProfile
            otherVC.currentUserUsername = nil // Reset current user name
            otherVC.isFollowing = false // Reset following status
            otherVC.resetUI() // Ensure UI is reset
        }
    }
}
