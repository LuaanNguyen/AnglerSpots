// Luan Nguyen
// CSE335
// Phase II
//
//  Catch.swift
//  AnglerSpots

import Foundation
import SwiftData

@Model
final class Catch {
    var date: Date  // when the fish was caught
    var species: String  // "Bass", "Trout", "Catfish",...
    var lengthCM: Double  // cm
    var weightKG: Double  // kg
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
