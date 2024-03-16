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
}

class MyProfileVC: UIViewController, ProfileChanger {

    @IBOutlet weak var myProfileImage: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var qrCode: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Circular crop for profile picture
        myProfileImage.layer.cornerRadius = myProfileImage.layer.frame.height / 2
        
        if self.traitCollection.userInterfaceStyle == .dark {
            // do something
        }
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
