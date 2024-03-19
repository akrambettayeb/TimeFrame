//
//  MapViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 3/16/24.
//

import UIKit

// TODO: add hide keyboard
// TODO: need to fix nav controller back button (add self.dismiss) so that you dont keep adding things to stack when you are effectively going back
// TODO: need to fix search bar
// TODO: need to fix popover segues so they aren't modal and don't layer on the map screen when challenge is submitted.
// TODO: need to implement photo stream.

class MapViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load custom back button.
        setCustomBackImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Present popover for existing challenge location.
        segue.destination.preferredContentSize = CGSize(width: 250, height: 300)
        if let presentationController = segue.destination.popoverPresentationController {
            presentationController.delegate = self
        }
    }

}

extension MapViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
