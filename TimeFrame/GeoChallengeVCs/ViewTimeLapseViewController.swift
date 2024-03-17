//
//  ViewTimeLapseViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 3/16/24.
//

import UIKit

class ViewTimeLapseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setCustomBackImage()
    }
    

    // Set custom back button.
    func setCustomBackImage() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "arrow.backward")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "arrow.backward")
    }

}
