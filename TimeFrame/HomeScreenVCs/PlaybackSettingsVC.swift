//
//  PlaybackSettingsVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/1/24.
//
//  Project: TimeFrame
//  EID: kz4696
//  Course: CS371L


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
    var selectedPhotos: [AlbumPhoto]!
    var photosWithText: [UIImage]! = []
    let topLeftPoint = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        
        publicSwitch.isOn = false
        favoriteSwitch.isOn = false
        reversedSwitch.isOn = false
        self.setDateDropdown()
        self.setSpeedDropdown()
        generateTimeframeButton.layer.cornerRadius = 5
    }
    
    // Defines the type of dates for the date dropdown button
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
    
    // Defines the speed options for the speed dropdown button
    func setSpeedDropdown() {
        let allSpeeds = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "15", "20"]
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
        
        self.isPublic = publicSwitch.isOn
        self.isFavorite = favoriteSwitch.isOn
        self.isReversed = reversedSwitch.isOn
        performSegue(withIdentifier: "segueToViewTimeframeVC", sender: self)
    }
    
    func generateImageWithText(text: String, backgroundImage: UIImage, fontSize: CGFloat) -> UIImage? {
        // Create a UIGraphicsImageRenderer with the size of the background image
        let renderer = UIGraphicsImageRenderer(size: backgroundImage.size)

        // Render the image with text
        let imageWithText = renderer.image { context in
            // Draw the background image at the origin (top-left corner)
            backgroundImage.draw(at: .zero)

            // Define the font and attributes for the text
            let font = UIFont.systemFont(ofSize: fontSize)
            let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.white]

            // Calculate the size of the text
            let textSize = text.size(withAttributes: attributes)

            // Calculate the size of the background box
            let boxWidth = textSize.width + 20 // Adjust as needed
            let boxHeight = textSize.height + 10 // Adjust as needed
            let boxRect = CGRect(x: 0, y: 0, width: boxWidth, height: boxHeight)

            // Create a UIBezierPath for the background box
            let boxPath = UIBezierPath(rect: boxRect)

            // Set the fill color for the background box (semi-transparent black)
            UIColor.black.withAlphaComponent(0.5).setFill()

            // Fill the background box
            boxPath.fill()

            // Define the rectangle to draw the text
            let textRect = CGRect(x: 10, y: 5, width: textSize.width, height: textSize.height)

            // Draw the text in the specified rectangle with the defined attributes
            text.draw(in: textRect, withAttributes: attributes)
        }

        // Return the rendered image with text
        return imageWithText
    }
    
    //  Passes all necessary info to the next VC to play the TimeFrame with the correct settings
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        photosWithText = [UIImage]()
        if timeframeName == "" {
            timeframeName = nameTextField.text!
        }
        if segue.identifier == "segueToViewTimeframeVC",
           let nextVC = segue.destination as? ViewTimeframeVC {
            nextVC.timeframeName = self.timeframeName
            nextVC.isPublic = self.isPublic
            nextVC.isFavorite = self.isFavorite
            nextVC.isReversed = self.isReversed
            nextVC.selectedDate = self.selectedDate
            nextVC.selectedSpeed = self.selectedSpeed
            // If the user chooses the date option, superimposes text onto the images
            for photo in selectedPhotos {
                var imageDate = ""
                switch selectedDate {
                case "Date":
                    imageDate = photo.date
                case "Month":
                    imageDate = photo.month
                case "Year":
                    imageDate = photo.year
                default:
                    break
                }
                if imageDate.isEmpty {
                    imageDate = "Blank Date"
                }
                if selectedDate == "None" || imageDate.isEmpty {
                    photosWithText.append(photo.image.fixOrientation())
                } else {
                    if let newImage = generateImageWithText(text: imageDate, backgroundImage: photo.image, fontSize: 120.0) {
                        photosWithText.append(newImage.fixOrientation())
                    } else {
                        continue
                    }
                }
            }
            nextVC.selectedPhotos = photosWithText
        }
    }

    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       textField.resignFirstResponder()
       return true
    }

    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       self.view.endEditing(true)
    }

}
