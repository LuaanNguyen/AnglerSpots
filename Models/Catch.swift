//
//  Catch.swift
//  AnglerSpots
//
//  Created by Luan Thien Nguyen on 10/26/25.
//

import Foundation
import SwiftData

@Model
final class Catch {
    var date: Date
    var species: String
    var lengthCM: Double
    var weightKG: Double
    var notes: String?

    init(date: Date = .now,
         species: String,
         lengthCM: Double = 0,
         weightKG: Double = 0,
         notes: String? = nil) {
        self.date = date
        self.species = species
        self.lengthCM = lengthCM
        self.weightKG = weightKG
        self.notes = notes
    }
}
