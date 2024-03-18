//
//  PhotoStreamViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 3/16/24.
//

import UIKit

class PhotoStreamViewController: UIViewController {

    @IBOutlet weak var photoStreamTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setCustomBackImage()
    }
    
}
