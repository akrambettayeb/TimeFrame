//
//  ViewTimeLapseViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 3/16/24.
//
// Project: TimeFrame
// EID: mas23586
// Course: CS371L

import UIKit

class ViewTimeLapseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setCustomBackImage()
    }
    
    @IBAction func onViewAlbumButtonPressed(_ sender: Any) {
        self.present(ChallengeAlbumViewController(), animated: true)
    }
    
    @IBAction func onAddPhotoButtonPressed(_ sender: Any) {
        self.present(AddPhotoToChallengeViewController(), animated: true)
    }
    
    @IBAction func onBackButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
