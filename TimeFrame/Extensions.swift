//
//  Extensions.swift
//  TimeFrame
//
//  Created by Kate Zhang on 4/7/24.
//
//  Project: TimeFrame
//  EID: kz4696
//  Course: CS371L

import UIKit
import Photos
import FirebaseFirestore
import FirebaseAuth

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Expands height of the collection view based on content size
    func setGridSize(_ imageGrid: UICollectionView!) {
        if let flowLayout = imageGrid.collectionViewLayout as? UICollectionViewFlowLayout {
            let contentSize = flowLayout.collectionViewContentSize
            imageGrid.frame.size = CGSize(width: contentSize.width, height: contentSize.height)
            imageGrid.layoutIfNeeded()
        }
    }
    
    // Expands height of the scroll view based on content size
    func setProfileScrollHeight(_ scrollView: UIScrollView!, _ imageGrid: UICollectionView!) {
        let distToVC = imageGrid.convert(imageGrid.bounds, to: view)
        let distToTop = distToVC.origin.y
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: distToTop + imageGrid.frame.height + (self.tabBarController?.tabBar.frame.height)!)
        scrollView.showsVerticalScrollIndicator = false
    }
    
    // Set custom back button to a purple left arrow
    func setCustomBackImage() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "TabBarPurple")
        navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "arrow.backward")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "arrow.backward")
    }
    
    // Fetches photo data for a specific album and stores as a list of dictionaries
    func fetchPhotoData(for db: Firestore, for userID: String, for albumName: String, completion: @escaping ([AlbumPhoto]) -> Void) {
        var fetchedPhotoData: [AlbumPhoto] = []
        db.collection("users").document(userID).collection("albums").document(albumName).collection("photos").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching photos: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            for document in documents {
                var newPhoto = AlbumPhoto(UIImage(systemName: "person.crop.rectangle.stack.fill")!)
                if let photoURL = document.data()["url"] as? String {
                    newPhoto = AlbumPhoto(self.fetchPhotoFromURL(photoURL))
                }
                if let photoDate = document.data()["date"] as? String {
                    newPhoto.date = photoDate
                }
                if let photoMonth = document.data()["month"] as? String {
                    newPhoto.month = photoMonth
                }
                if let photoYear = document.data()["year"] as? String {
                    newPhoto.year = photoYear
                }
                fetchedPhotoData.append(newPhoto)
            }
            completion(fetchedPhotoData)
        }
    }
    
    func fetchPhotoFromURL(_ photoURL: String) -> UIImage {
            if let url = URL(string: photoURL),
               let imageData = try? Data(contentsOf: url) {
                let image = UIImage(data: imageData)
                return (image?.fixOrientation())!
            }
            return UIImage(systemName: "person.crop.rectangle.stack.fill")!
        }
    
    // Fetches photo URLs across all of the user's albums and stores the result as a dictionary
    func fetchAllAlbums(for db: Firestore, completion: @escaping ([String: [AlbumPhoto]]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            completion([:])
            return
        }
        var allAlbums: [String: [AlbumPhoto]] = [:]
        db.collection("users").document(userID).collection("albums").getDocuments {
            (snapshot, error) in
            if let error = error {
                print("Error fetching albums: \(error.localizedDescription)")
                completion([:])
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            // Iterates through all of the user's albums
            for document in documents {
                if let albumName = document.data()["name"] as? String {
                    self.fetchPhotoData(for: db, for: userID, for: albumName) { fetchedPhotoData in
                        allAlbums[albumName] = fetchedPhotoData
                        if allAlbums.count == documents.count {
                            completion(allAlbums)
                        }
                    }
                }
            }
        }
    }
    
    func fetchAllTimeframesFromFirestore(for db: Firestore, completion: @escaping ([String: TimeFrame]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            completion([:])
            return
        }
        
        db.collection("users").document(userID).collection("timeframes").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching timeframes: \(error.localizedDescription)")
                completion([:])
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                completion([:])
                return
            }
            
            for document in documents {
                let data = document.data()
                let name = data["name"] as? String ?? ""
                let gifURLString = data["gifURL"] as? String ?? ""
                let thumbnailURLString = data["thumbnailURL"] as? String ?? ""
                let isPrivate = data["isPrivate"] as? Bool ?? false
                let isFavorited = data["isFavorited"] as? Bool ?? false
                let selectedSpeed = data["selectedSpeed"] as? Float ?? 0.0
                let thumbnail = self.fetchPhotoFromURL(thumbnailURLString)
                if let gifURL = URL(string: gifURLString) {
                    let timeframe = TimeFrame(gifURL, thumbnail, name, isPrivate, isFavorited, selectedSpeed)
                    allTimeframes[name] = timeframe
                } else {
                    print("Error: Unable to create URL objects")
                }
            }
            
            completion(allTimeframes)
        }
    }

    // Fetch Geo-Challenges to display on map.
    func fetchChallenges(for db: Firestore) async {
        do {
            let geochallengeQuery = try await db.collection("geochallenges").getDocuments()
            challenges = []
            for document in geochallengeQuery.documents {
                var newChallenge = Challenge (
                    name: document.data()["name"] as! String,
                    coordinate: CLLocationCoordinate2D(latitude: (document.data()["coordinate"] as! GeoPoint).latitude, longitude: (document.data()["coordinate"] as! GeoPoint).longitude),
                    startDate: (document.data()["startDate"] as! Timestamp).dateValue(),
                    endDate: (document.data()["endDate"] as! Timestamp).dateValue(),
                    numViews: document.data()["numViews"] as! Int,
                    numLikes: document.data()["numLikes"] as! Int,
                    album: [])
                newChallenge.challengeID = document.documentID
                
                // Upload images to album.
                var album: [ChallengeImage] = []
                let albumQuery = try await db.collection("geochallenges").document(document.documentID).collection("album").getDocuments()

                let photoDocs = albumQuery.documents

                // Adds all photos to album.
                for photoDoc in photoDocs {
                    // Get photo data.
                    var challengeImage = ChallengeImage(image: UIImage(), numViews: 1, numLikes: 0, numFlags: 0, hidden: false, capturedTimestamp: .now)
                    if let photoURL = photoDoc.data()["url"] as? String {
                        challengeImage = ChallengeImage(image: self.fetchPhotoFromURL(photoURL), numViews: 1, numLikes: 0, numFlags: 0, hidden: false, capturedTimestamp: .now)
                    }

                    if let photoViews = document.data()["numViews"] as? Int {
                        challengeImage.numViews = photoViews
                    }

                    if let photoLikes = document.data()["numLikes"] as? Int {
                        challengeImage.numLikes = photoLikes
                    }

                    if let photoFlags = document.data()["numFlags"] as? Int {
                        challengeImage.numFlags = photoFlags
                    }

                    if let photoHidden = document.data()["hidden"] as? Bool {
                        challengeImage.hidden = photoHidden
                    }
                    
                    if let timestamp = document.data()["capturedTimestamp"] as? Timestamp {
                        challengeImage.capturedTimestamp = timestamp.dateValue()
                    }
                    album.append(challengeImage)
                }
                
                // Sort photos in descending order.
                newChallenge.album = album.sorted { $0.capturedTimestamp < $1.capturedTimestamp }
                challenges.append(newChallenge)
                
            }
                                  
        } catch {
            print("Error getting documents: \(error)")
        }
    }
}


extension UIImageView {
    func enableZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(pinchGesture)
    }
    
    @objc private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
}


extension UIImage {
    static func animatedGif(from images: [UIImage], from imageDuration: Float, name: String) -> URL? {
        let fileProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]  as CFDictionary
        let frameProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFDelayTime as String): imageDuration]] as CFDictionary
        
        let documentsDirectoryURL: URL? = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL: URL? = documentsDirectoryURL?.appendingPathComponent("\(name).gif")
        
        if let url = fileURL as CFURL? {
            if let destination = CGImageDestinationCreateWithURL(url, UTType.gif.identifier as CFString, images.count, nil) {
                CGImageDestinationSetProperties(destination, fileProperties)
                for image in images {
                    if let cgImage = image.cgImage {
                        CGImageDestinationAddImage(destination, cgImage, frameProperties)
                    }
                }
                if !CGImageDestinationFinalize(destination) {
                    print("Failed to finalize the image destination")
                }
                print("Url = \(fileURL!)")
                return fileURL
            }
        }
        return nil
    }
    
    public func flipVertically() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: self.size.width/2, y: self.size.height/2)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: -self.size.width/2, y: -self.size.height/2)
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRectMake(0, 0, self.size.width, self.size.height))
        guard let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return self
        }
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
