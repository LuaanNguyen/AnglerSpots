// Luan Nguyen
// CSE335
// Phase I
//
//  Spot.swift
//  AnglerSpots
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Spot {
    // this is representing a fishing spot
    @Attribute(.unique) var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var notes: String?
    var speciesTags: [String]
    var catches: [Catch]

    init(id: UUID = UUID(),
         name: String,
         latitude: Double,
         longitude: Double,
         notes: String? = nil,
         speciesTags: [String] = [],
         catches: [Catch] = []) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
        self.speciesTags = speciesTags
        self.catches = catches
    }

    // Convenience coordinate for MapKit annotations and camera positioning
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
