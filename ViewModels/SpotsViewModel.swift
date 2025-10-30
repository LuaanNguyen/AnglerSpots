// Luan Nguyen
// CSE335
// Phase I
//
//  SpotsViewModel.swift
//  AnglerSpots


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

    init() {}

    // Indicates when the ModelContext has been injected and the VM is ready.
    // Injects the SwiftData context and performs initial load.
    var isInitialized: Bool { context != nil }

    func setContext(_ context: ModelContext) {
        self.context = context
        loadSpots()
    }

    // Loads all Spot records
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

    // this func reates and persists a new Spot
    // then refreshes the in-memory list
    func addSpot(name: String, lat: Double, lon: Double, notes: String? = nil) {
        guard let context else { return }
        let spot = Spot(name: name, latitude: lat, longitude: lon, notes: notes)
        context.insert(spot)
        save()
        loadSpots()
    }

    // save pending changes to the SwiftData
    func save() {
        guard let context else {
            return
        }
        do { try context.save() } catch { print("Save error:", error) }
    }

    // Returns either all spots or those matching the current search text
    var filteredSpots: [Spot] {
        guard !searchText.isEmpty else {
            return spots
        }
        
        return spots.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}
