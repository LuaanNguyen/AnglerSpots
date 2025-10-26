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

    init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double, notes: String? = nil, speciesTags: [String] = [], catches: [Catch] = []) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
        self.speciesTags = speciesTags
        self.catches = catches
    }

    var coordinate: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }
}

// Models/Catch.swift
import Foundation
import SwiftData

@Model
final class Catch {
    var date: Date
    var species: String
    var lengthCM: Double
    var weightKG: Double
    var notes: String?

    init(date: Date = .now, species: String, lengthCM: Double = 0, weightKG: Double = 0, notes: String? = nil) {
        self.date = date
        self.species = species
        self.lengthCM = lengthCM
        self.weightKG = weightKG
        self.notes = notes
    }
}
