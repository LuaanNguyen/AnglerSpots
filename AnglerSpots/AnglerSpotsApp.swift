//
//  AnglerSpotsApp.swift
//  AnglerSpots
//
//  Created by Luan Thien Nguyen on 10/26/25.
//

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
