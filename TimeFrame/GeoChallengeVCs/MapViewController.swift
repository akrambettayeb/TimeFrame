//
//  MapViewController.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 3/16/24.
//
// Project: TimeFrame
// EID: mas23586
// Course: CS371L


import UIKit
import MapKit
import FirebaseFirestore
import FirebaseAuth

// TODO: add hide keyboard
// TODO: need to fix nav controller back button (add self.dismiss) so that you dont keep adding things to stack when you are effectively going back
// TODO: need to fix search bar
// TODO: need to fix popover segues so they aren't modal and don't layer on the map screen when challenge is submitted.
// TODO: need to implement photo stream.
//TODO: add alert to tell user to press to add location (instructions)
//TODO: figure out why pins persisted
// TODO: generate timeframe with current album when active, save timeframe when not active
// TODO: add example for inactive timeframe (new popover)
// TODO: ask to make sure that user wants to move on without saving image?
//TODO: add time added field to album photos and sort for timeframes
// TODO: add firestore support for existing challenges
// TODO: page view controller for screens from popovers
// TODO: fix album preview images (index) and sorting
// TODO: add notification for successfully creating/adding to challenge


// TODO: sort albums by date taken

var challenges: [Challenge] = [] // TODO: may need a new class for challenges AND need to store in firestore

public func getDateString(date: Date) -> String {
    let day = Calendar.current.dateComponents([.day], from: date)
    let month = Calendar.current.dateComponents([.month], from: date)
    let year = Calendar.current.dateComponents([.year], from: date)
    var dayString = String(describing: day.day!)
    dayString = dayString.count == 1 ? "0" + dayString : dayString
    var monthString = String(describing: month.month!)
    monthString = monthString.count == 1 ? "0" + monthString : monthString
    let yearString = String(describing: (year.year! % 100))
    
    return "\(monthString)/\(dayString)/\(yearString)"
}

class MapViewController: UIViewController, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UIPopoverControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D?
    var newChallenge: MapPin?
    let db = Firestore.firestore()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocationServices()
        mapView.delegate = self
        
        Task {
            // Fetch challenges.
            await self.fetchChallenges(for: self.db)
            
            // Present challenges.
            for challenge in challenges {
                let pin = MapPin(coordinate: challenge.coordinate, challenge: challenge)
                mapView.addAnnotation(pin)
            }
            
            mapView.reloadInputViews()
        }
        
        // Load custom back button.
        setCustomBackImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO: make sure purple pin shows up
        super.viewWillAppear(animated)
        
        // Present challenges.
        for challenge in challenges {
            let pin = MapPin(coordinate: challenge.coordinate, challenge: challenge)
            mapView.addAnnotation(pin)
        }
        
        mapView.reloadInputViews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ExistingChallengeSegue" {
            // Present popover for existing challenge location.
            segue.destination.preferredContentSize = CGSize(width: 250, height: 300)
            if let presentationController = segue.destination.popoverPresentationController {
                presentationController.delegate = self
            }
        } else if segue.identifier == "NewChallengeSegue",
                  let destination = segue.destination as? AddChallengeInfoViewController
        {
            destination.challengeLocation = newChallenge
        }
    }
    
    func presentInstructions() {
        // Create alert to tell user how to use this screen.
        let instructionVC = UIAlertController(title: "Instructions", message: "Press and hold on map to create a Geo-Challenge. Select pin to view existing Geo-Challenge. Tap on cloud button to refresh challenge map.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        instructionVC.addAction(okAction)
        present(instructionVC, animated: true)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            return .none
        }

    func configureLocationServices() {
        locationManager.delegate = self
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
            
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            presentInstructions()
            break
            
        default:
            print("Access denied.") //TODO: show some error and segue if access denied
            break
        }
    }
    
    //From Apple documentation.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:  // Location services are available.
            mapView.showsUserLocation = true
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.startUpdatingLocation()
            presentInstructions()
            break

        case .notDetermined:        // Authorization not determined yet.
            manager.requestWhenInUseAuthorization()
            break

        default:
            print("Access denied.") //TODO: show some error and segue if access denied
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did get latest location.")
        
        // Update current location on map.
        guard let latestLocation = locations.first else { return }
        if currentCoordinate == nil {
            zoomToLatestLocation(with: latestLocation.coordinate)
        }
        currentCoordinate = latestLocation.coordinate
    }
    
    func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(zoomRegion, animated: true)
    }

    @IBAction func onLongPress(recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == UIGestureRecognizer.State.began else { return }
        
        // Add haptic feedback.
        UIImpactFeedbackGenerator.init(style: .heavy).impactOccurred()
        
        // Get coordinates at point that user tapped at.
        let touchLocation = recognizer.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        
        // Add pin to map for new challenge location.
        newChallenge = MapPin(coordinate: CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude), challenge: Challenge(name: "", coordinate: CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude), startDate: .now, endDate: .now, numViews: 1, numLikes: 0, album: []))
        performSegue(withIdentifier: "NewChallengeSegue", sender: self)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            // Current user location.
            return nil
        }

        let pinID = "pinID"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinID) as? MKMarkerAnnotationView
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: pinID)
            pinView!.glyphImage = UIImage(systemName: "camera.fill")
            pinView!.glyphTintColor = .white
            pinView!.markerTintColor = UIColor(named: "TabBarPurple")
            pinView!.canShowCallout = false
            pinView!.animatesWhenAdded = true
        } else {
            // Update reused annotation.
            pinView!.annotation = annotation
        }

        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Check if the annotation is a MapPin.
        guard let pin = view.annotation as? MapPin else {
            return
        }
        
        // Create and configure callout view.
        mapView.deselectAnnotation(view.annotation, animated: true)
        let calloutVC = createCalloutViewController(annotation: pin)
        calloutVC.modalPresentationStyle = .popover
        calloutVC.preferredContentSize = CGSize(width: 260, height: 300)
        calloutVC.popoverPresentationController!.delegate = self
        calloutVC.popoverPresentationController!.backgroundColor = UIColor(named: "TabBarPurple")
        calloutVC.popoverPresentationController!.permittedArrowDirections = [.up, .down]
        calloutVC.popoverPresentationController!.sourceView = view.superview!
        calloutVC.popoverPresentationController!.sourceRect = view.frame
        self.present(calloutVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none;
    }
    
    func createCalloutViewController(annotation: MapPin) -> UIViewController {
        // Check if we need to create active or inactive callout view.
        let endDay = Calendar.current.dateComponents([.day], from: annotation.challenge.endDate).day!
        let thisDay = Calendar.current.dateComponents([.day], from: .now).day!
        let endMonth = Calendar.current.dateComponents([.month], from: annotation.challenge.endDate).month!
        let thisMonth = Calendar.current.dateComponents([.month], from: .now).month!
        let endYear = Calendar.current.dateComponents([.year], from: annotation.challenge.endDate).year!
        let thisYear = Calendar.current.dateComponents([.year], from: .now).year!
        
        if endYear <= thisYear && endMonth <= thisMonth && endDay < thisDay {
            // Challenge is inactive.
            let calloutVC = self.storyboard?.instantiateViewController(withIdentifier: "inactiveCalloutVC") as! InactiveChallengeViewController
            calloutVC.challenge = annotation.challenge
            return calloutVC
        } else {
            let calloutVC = self.storyboard?.instantiateViewController(withIdentifier: "activeCalloutVC") as! ActiveChallengeViewController
            calloutVC.challenge = annotation.challenge
            return calloutVC
        }
    }
    
    // Refresh challenge map.
    @IBAction func onReloadButtonPressed(_ sender: Any) {
        Task {
            // Fetch challenges.
            await fetchChallenges(for: self.db)
            
            // Present challenges.
            for challenge in challenges {
                let pin = MapPin(coordinate: challenge.coordinate, challenge: challenge)
                mapView.addAnnotation(pin)
            }
            
            mapView.reloadInputViews()
        }
    }
}


