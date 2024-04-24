//
//  MapPin.swift
//  TimeFrame
//
//  Created by Megan Sundheim on 4/23/24.
//
// Project: TimeFrame
// EID: mas23586
// Course: CS371L

import UIKit
import MapKit

class MapPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var challenge: Challenge
    
    init(coordinate: CLLocationCoordinate2D, challenge: Challenge) {
        self.coordinate = coordinate
        self.challenge = challenge
    }
}
