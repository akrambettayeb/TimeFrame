//
//  PhotoStreamViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 3/16/24.
//
// Project: TimeFrame
// EID: mas23586
// Course: CS371L

import UIKit

class PhotoStreamViewController: UIViewController {

    @IBOutlet weak var photoStreamTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setCustomBackImage()
    }
    
}
