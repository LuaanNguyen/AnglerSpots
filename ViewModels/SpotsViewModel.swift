//
//  SpotsViewModel.swift
//  AnglerSpots
//
//  Created by Luan Thien Nguyen on 10/26/25.
//

import Foundation
import SwiftData
import CoreLocation
import Combine

@MainActor
final class SpotsViewModel: ObservableObject {
    @Published var spots: [Spot] = []
    @Published var searchText: String = ""
    @Published var selectedSpot: Spot?
    private var context: ModelContext?

    // Empty init so SwiftUI can create safely
    init() {}

    var isInitialized: Bool { context != nil }

    func setContext(_ context: ModelContext) {
        self.context = context
        loadSpots()
    }

    func loadSpots() {
        guard let context else { return }
        do {
            let descriptor = FetchDescriptor<Spot>(sortBy: [SortDescriptor(\.name)])
            spots = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch spots:", error)
            spots = []
        }
    }

    func addSpot(name: String, lat: Double, lon: Double, notes: String? = nil) {
        guard let context else { return }
        let spot = Spot(name: name, latitude: lat, longitude: lon, notes: notes)
        context.insert(spot)
        save()
        loadSpots()
    }

    func save() {
        guard let context else { return }
        do { try context.save() } catch { print("Save error:", error) }
    }

    var filteredSpots: [Spot] {
        guard !searchText.isEmpty else { return spots }
        return spots.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}
