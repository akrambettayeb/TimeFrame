//
//  MapViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 3/16/24.
//

import UIKit

class MapViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load custom back button.
        setCustomBackImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.preferredContentSize = CGSize(width: 250, height: 300)
        if let presentationController = segue.destination.popoverPresentationController {
            presentationController.delegate = self
        }
    }

} //TODO: add hide keyboard

extension MapViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
