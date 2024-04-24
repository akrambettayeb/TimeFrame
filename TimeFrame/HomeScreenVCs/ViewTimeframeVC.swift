//  ViewTimeFrameVC.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/1/24.
//
//  Project: TimeFrame
//  EID: kz4696
//  Course: CS371L


import Foundation
import UIKit
import UniformTypeIdentifiers
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class ViewTimeframeVC: UIViewController {
    var timeframeName: String!
    var isPublic: Bool!
    var isFavorite: Bool!
    var isReversed: Bool!
    var selectedDate: String!
    var selectedSpeed: String!
    var selectedPhotos: [UIImage]!
    var gifDuration: Float!
    let db = Firestore.firestore()
    let storage = Storage.storage()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    var imageDuration: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCustomBackImage()
        self.title = timeframeName
        shareButton.layer.cornerRadius = 5
        animateImage()
    }
    
    func animateImage() {
        if isReversed {
            selectedPhotos = selectedPhotos.reversed()
        }
        let speedComponents = selectedSpeed.components(separatedBy: " ")
        let actualSpeed = Float(speedComponents[0])!
        gifDuration = Float(selectedPhotos.count) / actualSpeed
        // Calculates the duration for each image
        imageDuration = gifDuration / Float(selectedPhotos.count)
        imageView.animationDuration = TimeInterval(gifDuration)
        imageView.animationImages = selectedPhotos
        imageView.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageView.animationImages = nil   // Release the memory from animating images
    }
    
    // Adds the TimeFrame to the local array of all created TimeFrames and unwind segues back to the main home screen
    @IBAction func onSaveTapped(_ sender: UIBarButtonItem) {
        if isReversed {
            selectedPhotos = selectedPhotos.reversed()
        }
        let gifURL = UIImage.animatedGif(from: selectedPhotos, from: imageDuration, name: timeframeName)
        var gifItem: Any = ""
        if gifURL != nil {
            gifItem = gifURL!
        } else {
            // Share first photo in array if there is an error generating the GIF
            gifItem = selectedPhotos[0]
        }
        let newTimeframe = TimeFrame(gifItem as! URL, selectedPhotos[0], timeframeName, isPublic, isFavorite, gifDuration)
        allTimeframes[timeframeName] = newTimeframe
        timeframeNames.append(timeframeName)
        timeframeNames = timeframeNames.sorted()
        // uploadGIFAndThumbnail(timeframe: newTimeframe)
        print("done")
        performSegue(withIdentifier: "unwindViewTimeframeToHome", sender: self)
    }
    
    func uploadGIFAndThumbnail(timeframe: TimeFrame) {
        // Upload GIF to Firebase Storage
        guard let userID = Auth.auth().currentUser?.uid else {
                print("User not authenticated")
                return
            }
        
        guard let gifData = try? Data(contentsOf: timeframe.url) else {
            return // Handle error
        }
        
        let gifRef = storage.reference().child("users").child(userID).child("timeframes").child(timeframe.name).child("\(timeframe.name).gif")
        gifRef.putData(gifData, metadata: nil) { [weak self] metadata, error in
            guard let self = self else { return }
            guard let _ = metadata else {
                print("Error uploading GIF: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            print("1")
            // Get download URL of the uploaded GIF
            gifRef.downloadURL { url, error in
                guard let gifURL = url else {
                    print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Upload thumbnail image to Firebase Storage
                guard let thumbnailData = timeframe.thumbnail.jpegData(compressionQuality: 0.8) else {
                    return // Handle error
                }
                
                let thumbnailRef = self.storage.reference().child("users").child(userID).child("timeframes").child(timeframe.name).child("\(timeframe.name).jpg")
                thumbnailRef.putData(thumbnailData, metadata: nil) { metadata, error in
                    guard let _ = metadata else {
                        print("Error uploading thumbnail: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    // Get download URL of the uploaded thumbnail
                    thumbnailRef.downloadURL { url, error in
                        guard let thumbnailURL = url else {
                            print("Error getting thumbnail download URL: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        
                        // Once both GIF and thumbnail are uploaded, you can proceed to save their URLs to Firestore
                        print("hi")
                        self.saveTimeframeToFirestore(gifURL: gifURL, thumbnailURL: thumbnailURL, timeframe: timeframe)
                        
                    }
                }
            }
        }
    }
    
    func saveTimeframeToFirestore(gifURL: URL, thumbnailURL: URL, timeframe: TimeFrame) {
        print("testing")
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let timestamp = FieldValue.serverTimestamp()
        
        let timeframeData: [String: Any] = [
            "gifURL": gifURL.absoluteString,
            "thumbnailURL": thumbnailURL.absoluteString,
            "name": timeframe.name,
            "isPrivate": timeframe.isPrivate,
            "isFavorited": timeframe.isFavorited,
            "selectedSpeed": timeframe.selectedSpeed,
            // Add any other properties you want to save
        ]
        
        // Add a new document to the "timeframes" collection under the user's ID
        db.collection("users").document(userID).collection("timeframes").document(timeframe.name).setData(timeframeData) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Timeframe document added successfully")
                // Handle successful save (e.g., dismiss view controller)
                //self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // Shares the TimeFrame as a GIF to the user's other apps when the "Share" button is tapped
    @IBAction func onShareTapped(_ sender: UIButton) {
        var shareItem: Any = ""
        let gifURL = UIImage.animatedGif(from: selectedPhotos, from: imageDuration, name: timeframeName)
        
        if gifURL != nil {
            shareItem = gifURL!
        } else {
            // Share first photo in array if there is an error generating the GIF
            shareItem = selectedPhotos[0]
        }
        let activityController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}
