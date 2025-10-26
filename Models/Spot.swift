//
//  Spot.swift
//  AnglerSpots
//
//  Created by Luan Thien Nguyen on 10/26/25.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Spot {
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

    // Computed only – not persisted
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
