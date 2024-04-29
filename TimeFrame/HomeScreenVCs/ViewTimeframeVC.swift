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
        let gif = UIImage.animatedGif(from: selectedPhotos, from: imageDuration, name: timeframeName)
        var gifItem: Any = ""
        if gif != nil {
            gifItem = gif!
        } else {
            // Share first photo in array if there is an error generating the GIF
            gifItem = selectedPhotos[0]
        }
        let newTimeframe = TimeFrame(gifItem as! URL, selectedPhotos[0], timeframeName, !(isPublic), isFavorite, gifDuration)
        allTimeframes[timeframeName] = newTimeframe
        timeframeNames.append(timeframeName)
        timeframeNames = timeframeNames.sorted()
        uploadThumbnailAndGIF(timeframe: newTimeframe) { thumbnailURL, gifURL in
            if let thumbnailURL = thumbnailURL, let gifURL = gifURL {
                // Both thumbnail and GIF URLs are available here
                print("Thumbnail URL: \(thumbnailURL)")
                print("GIF URL: \(gifURL)")

                // Now you can call saveTimeframeToFirestore or perform any other action with the URLs
                self.saveTimeframeToFirestore(gifURL: gifURL, thumbnailURL: thumbnailURL, timeframe: newTimeframe)
            } else {
                print("Failed to upload thumbnail or GIF.")
            }
        }
        print("done")
        performSegue(withIdentifier: "unwindViewTimeframeToHome", sender: self)
    }
    
    func uploadPhoto(timeframe: TimeFrame, completion: @escaping (String?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Invalid album name, image data, or user not authenticated")
            completion(nil)
            return
        }
        
        guard let imageData = timeframe.thumbnail.jpegData(compressionQuality: 0.5) else {
            print("Error: Unable to convert thumbnail image to data.")
            completion(nil)
            return
        }
        
        let storageRef = self.storage.reference().child("users").child(userID).child("timeframes").child(timeframe.name).child("\(timeframe.name).jpg")
        
        storageRef.putData(imageData, metadata: nil) { [weak self] (metadata, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
                completion(nil)
            } else {
                storageRef.downloadURL { (url, error) in
                    if let downloadURL = url?.absoluteString {
                        completion(downloadURL)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }

    
    func uploadGIF(timeframe: TimeFrame, completion: @escaping (URL?) -> Void) {
        // Upload GIF to Firebase Storage
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            completion(nil)
            return
        }
        
        guard let gifData = try? Data(contentsOf: timeframe.url) else {
            print("Error: Unable to get GIF data.")
            completion(nil)
            return
        }
        
        let gifRef = storage.reference().child("users").child(userID).child("timeframes").child(timeframe.name).child("\(timeframe.name).gif")
        
        gifRef.putData(gifData, metadata: nil) { [weak self] metadata, error in
            guard let self = self else { return }
            guard let _ = metadata else {
                print("Error uploading GIF: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            // Get download URL of the uploaded GIF
            gifRef.downloadURL { url, error in
                guard let gifURL = url else {
                    print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                    return
                }
                
                // Once the GIF is uploaded, pass its URL back to the caller
                completion(gifURL)
            }
        }
    }


    func uploadThumbnailAndGIF(timeframe: TimeFrame, completion: @escaping (String?, URL?) -> Void) {
        var thumbnailURL: String?
        var timeframeURL: URL?

        let dispatchGroup = DispatchGroup()

        // Upload thumbnail
        dispatchGroup.enter()
        uploadPhoto(timeframe: timeframe) { url in
            if let imageURL = url {
                print("Uploaded thumbnail URL: \(imageURL)")
                thumbnailURL = imageURL
            } else {
                print("Failed to upload thumbnail.")
            }
            dispatchGroup.leave()
        }

        // Upload GIF
        dispatchGroup.enter()
        uploadGIF(timeframe: timeframe) { url in
            if let gifURL = url {
                print("Uploaded GIF URL: \(gifURL)")
                timeframeURL = url
            } else {
                print("Failed to upload GIF.")
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            // Both closures have completed
            completion(thumbnailURL, timeframeURL)
        }
    }
    
    func saveTimeframeToFirestore(gifURL: URL, thumbnailURL: String, timeframe: TimeFrame) {
        print("testing")
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let timestamp = FieldValue.serverTimestamp()
        
        let timeframeData: [String: Any] = [
            "gifURL": gifURL.absoluteString,
            "thumbnailURL": thumbnailURL,
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
        let gifURL = UIImage.animatedGif(from: selectedPhotos, from: imageDuration, name: timeframeName)
        var gifItem: Any = ""
        if gifURL != nil {
            gifItem = gifURL!
        } else {
            // Share first photo in array if there is an error generating the GIF
            gifItem = selectedPhotos[0]
        }
        let newTimeframe = TimeFrame(gifItem as! URL, selectedPhotos[0], timeframeName, isPublic, isFavorite, gifDuration)
        let activityController = UIActivityViewController(activityItems: [newTimeframe.url], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}
