// Luan Nguyen
// CSE335
// Phase II
//
//  LocationManager.swift
//  AnglerSpots


import Foundation
import CoreLocation

import Combine

// This class handles all GPS/location stuff -
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined  // permission status
    @Published var currentLocation: CLLocation?  // user's current GPS location

    private let manager = CLLocationManager()  // iOS location manager

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest  // use best GPS accuracy
    }

    // Called when we want to get the user's location
    func request() {
        manager.requestWhenInUseAuthorization()  // ask for location permission
        manager.startUpdatingLocation()
    }

    // Delegate: reflect authorization changes into a published property
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        // if permission granted, start updating location
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    // Delegate: publish the most recent location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last  // get the most recent location
    }
}
