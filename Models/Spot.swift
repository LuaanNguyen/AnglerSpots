// Luan Nguyen
// CSE335
// Phase II
//
//  Spot.swift
//  AnglerSpots
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Spot: Identifiable {
    // this is representing a fishing spot
    @Attribute(.unique) var id: UUID
    var name: String
    
    var latitude: Double
    var longitude: Double
    
    var notes: String?  // optional notes about the spot
    var speciesTags: [String]  // list of fish species found here
    var catches: [Catch]  // all the catches logged at this spot
    var locationType: String  // e.g., "Lake", "River", "Ocean", "Pond"

    init(id: UUID = UUID(),
         name: String,
         latitude: Double,
         longitude: Double,
         notes: String? = nil,
         speciesTags: [String] = [],
         catches: [Catch] = [],
         locationType: String = "Lake") {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
        self.speciesTags = speciesTags
        self.catches = catches
        self.locationType = locationType
    }

    // Convenience coordinate for MapKit annotations and camera positioning
    // this converts lat/lon to CLLocationCoordinate2D which MapKit needs
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
