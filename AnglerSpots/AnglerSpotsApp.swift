// Luan Nguyen
// CSE335
// Phase II
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
        .modelContainer(for: [Spot.self, Catch.self])
    }
}
