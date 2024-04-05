//
//  PlaybackSettingsVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/1/24.
//

import UIKit

class PlaybackSettingsVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var publicSwitch: UISwitch!
    @IBOutlet weak var favoriteSwitch: UISwitch!
    @IBOutlet weak var reversedSwitch: UISwitch!
    @IBOutlet weak var generateTimeframeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        
        nameTextField.delegate = self
        publicSwitch.isOn = false
        favoriteSwitch.isOn = false
        reversedSwitch.isOn = false
        generateTimeframeButton.layer.cornerRadius = 5
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
       textField.resignFirstResponder()
       return true
    }

    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       self.view.endEditing(true)
    }

}
