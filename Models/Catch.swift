// Luan Nguyen
// CSE335
// Phase I
//
//  Catch.swift
//  AnglerSpots

import Foundation
import SwiftData

@Model
final class Catch {
    // info for a single catch made at a spot
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
