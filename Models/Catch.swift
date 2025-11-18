// Luan Nguyen
// CSE335
// Phase II
//
//  Catch.swift
//  AnglerSpots

import Foundation
import SwiftData


// @Model makes this a SwiftData model so catches are saved permanently
@Model
final class Catch {
    var date: Date  // when the fish was caught
    var species: String  // (e.g., "Bass", "Trout")
    var lengthCM: Double  // cm
    var weightKG: Double  // kg
    var notes: String?  // optional

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
