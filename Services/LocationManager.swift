// Luan Nguyen
// CSE335
// Phase I
//
//  LocationManager.swift
//  AnglerSpots


import Foundation
import CoreLocation
import Combine

//  Lightweight wrapper around CLLocationManager.
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    // requests permission and begins location updates
    func request() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    // Delegate: reflect authorization changes into a published property
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
    }

    // Delegate: publish the most recent location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
}
