// Luan Nguyen
// CSE335
// Phase I
//
//  AnglerSpotsApp.swift
//  AnglerSpots


import SwiftUI
import SwiftData

@main
struct AnglerSpotsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // shared SwiftData container to app
        .modelContainer(for: [Spot.self, Catch.self])
    }
}
