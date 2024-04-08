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
    @IBOutlet weak var datesButton: UIButton!
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var generateTimeframeButton: UIButton!
    
    var timeframeName = ""
    var isPublic = false
    var isFavorite = false
    var isReversed = false
    var selectedDate = ""
    var selectedSpeed = ""
    var selectedPhotos: [UIImage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        
        nameTextField.delegate = self
        publicSwitch.isOn = false
        favoriteSwitch.isOn = false
        reversedSwitch.isOn = false
        self.setDateDropdown()
        self.setSpeedDropdown()
        generateTimeframeButton.layer.cornerRadius = 5
    }
    
    func setDateDropdown() {
        let dates = ["Date", "Month", "Year", "None"]
        var dateItems: [UIMenuElement] = []
        for date in dates {
            let dateItem = UIAction(title: date) { _ in
                self.selectedDate = date
                self.datesButton.setTitle(date, for: .normal)
            }
            dateItems.append(dateItem)
        }
        
        let menu = UIMenu(title: "Displayed Date Type", options: .displayInline, children: dateItems)
        datesButton.menu = menu
        datesButton.showsMenuAsPrimaryAction = true
    }
    
    func setSpeedDropdown() {
        let allSpeeds = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"]
        var speedItems: [UIMenuElement] = []
        for speed in allSpeeds {
            let speedTitle = "\(speed) FPS"
            let speedItem = UIAction(title: speedTitle) { _ in
                self.selectedSpeed = speedTitle
                self.speedButton.setTitle(speedTitle, for: .normal)
            }
            speedItems.append(speedItem)
        }
        let menu = UIMenu(title: "Speed of TimeFrame", options: .displayInline, children: speedItems)
        speedButton.menu = menu
        speedButton.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func onMakeTapped(_ sender: Any) {
        let timeframeName = nameTextField.text!
        // Checks that user entered a name for the Timeframe
        if timeframeName.isEmpty {
            let alert = UIAlertController(title: "Invalid TimeFrame Name", message: "Please enter a valid TimeFrame name. ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        // Checks if the name for the Timeframe is unique
        if timeframeNames.contains(timeframeName) {
            let alert = UIAlertController(title: "Timeframe Name Not Unique", message: "This name has already been used before, please enter a new name. ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        // Checks that user selected a date from the dropdown
        if selectedDate == "" {
            let alert = UIAlertController(title: "No Date Selected", message: "Please select a date from the dropdown menu. ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        // Checks that user selected a speed from the dropdown
        if selectedSpeed == "" {
            let alert = UIAlertController(title: "No Speed Selected", message: "Please selected a speed from the dropdown menu. ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        
        performSegue(withIdentifier: "segueToViewTimeframeVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToViewTimeframeVC",
           let nextVC = segue.destination as? ViewTimeframeVC {
            nextVC.timeframeName = self.timeframeName
            nextVC.isPublic = self.isPublic
            nextVC.isFavorite = self.isFavorite
            nextVC.isReversed = self.isReversed
            nextVC.selectedDate = self.selectedDate
            nextVC.selectedSpeed = self.selectedSpeed
            nextVC.selectedPhotos = self.selectedPhotos
        }
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
