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

// TODO: add hide keyboard
// TODO: need to fix nav controller back button (add self.dismiss) so that you dont keep adding things to stack when you are effectively going back
// TODO: need to fix search bar
// TODO: need to fix popover segues so they aren't modal and don't layer on the map screen when challenge is submitted.
// TODO: need to implement photo stream.
//TODO: add alert to tell user to press to add location (instructions)

var challengeLocations: [MKPointAnnotation] = [] // TODO: may need a new class for challenges AND need to store in firestore

class MapViewController: UIViewController, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D?
    var newChallenge: MKPointAnnotation?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocationServices()

        // Load custom back button.
        setCustomBackImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Present challenges.
        for challenge in challengeLocations {
            mapView.addAnnotation(challenge)
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
        let instructionVC = UIAlertController(title: "Instructions", message: "Press and hold on map to create a Geo-Challenge. Select pin to view existing Geo-Challenge.", preferredStyle: .alert)
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
    
    //TODO: add vibration on long tap
    // TODO: change pin color
    @IBAction func onLongPress(recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == UIGestureRecognizer.State.began else { return }
        
        // Get coordinates at point that user tapped at.
        let touchLocation = recognizer.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        
        // Add pin to map for new challenge location.
        newChallenge = MKPointAnnotation()
        newChallenge!.coordinate = CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        performSegue(withIdentifier: "NewChallengeSegue", sender: self)
    }
}

