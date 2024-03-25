//
//  SelfieViewController.swift
//  TimeFrame
//
//  Created by Akram Bettayeb on 3/6/24.
//
// Project: TimeFrame
// EID: aab4889
// Course: CS371L

import UIKit

class SelfieViewController: UIViewController {

    
    // camera view
    @IBOutlet weak var cameraView: UIView!
    // onion skin camera overlay image - may be null if this is the first image in an album
    @IBOutlet weak var onionSkinImageView: UIImageView!
    // camera button
    @IBOutlet weak var cameraButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // change opacity of the onionSkinImage
        onionSkinImageView.alpha = 0.5
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
