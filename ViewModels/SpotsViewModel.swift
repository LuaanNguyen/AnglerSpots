// Luan Nguyen
// CSE335
// Phase II
//
//  SpotsViewModel.swift
//  AnglerSpots


import Foundation
import SwiftData
import CoreLocation

import Combine

// enum for sort options
enum SortOption: String, CaseIterable {
    case name = "Name"
    case distance = "Distance"
    case catches = "Most Catches"
    case recent = "Most Recent"
}

// ViewModelhandles all the business logic and data operations
@MainActor
final class SpotsViewModel: ObservableObject {
    @Published var spots: [Spot] = []  // list of all fishing spots
    
    @Published var searchText: String = ""  // text from search bar
    
    @Published var selectedSpot: Spot?  // currently selected spot
    @Published var selectedSpeciesFilter: String = "All"  // filter by fish species
    @Published var selectedLocationTypeFilter: String = "All"  // filter by location typ
    
    @Published var searchNearby: Bool = false  // toggle for nearby search
    
    @Published var sortOption: SortOption = .name  // how to sort the list
    
    @Published var userLocation: CLLocation?  // user's current GPS location
    private var context: ModelContext?  // SwiftData context for database operations

    init() {}

    // Indicates when the ModelContext has been injected and the VM is ready.
    var isInitialized: Bool {
        context != nil    // Injects the SwiftData context and performs initial load.
    }

    // set the SwiftData context
    func setContext(_ context: ModelContext) {
        self.context = context
        loadSpots()
        
        // add some sample spots if empty
        if spots.isEmpty {
            populateSampleData()
        }
    }
    
    private func populateSampleData() {
        guard let context else { return }
        
        let tempeTownLake = Spot(
            name: "Tempe Town Lake",
            latitude: 33.4278,
            longitude: -111.9376,
            notes: "Great urban fishing spot. I wouldn't eat them in here. Watch for small carps near the bridges.",
            locationType: "Lake"
        )
        tempeTownLake.speciesTags = ["Largemouth Bass", "Catfish", "Bluegill"]
        
        let catch1 = Catch(date: Date().addingTimeInterval(-7 * 24 * 3600), species: "Largemouth Bass", lengthCM: 38.0, weightKG: 1.2, notes: "Caught near the marina dock with senko")
        let catch2 = Catch(date: Date().addingTimeInterval(-14 * 24 * 3600), species: "Catfish", lengthCM: 45.0, weightKG: 1.8, notes: "Big one! Used chicken liver as bait")
        let catch3 = Catch(date: Date().addingTimeInterval(-3 * 24 * 3600), species: "Largemouth Bass", lengthCM: 32.0, weightKG: 0.9, notes: nil)
        context.insert(catch1)
        context.insert(catch2)
        context.insert(catch3)
        tempeTownLake.catches = [catch1, catch2, catch3]
        context.insert(tempeTownLake)
        
        let saltRiver = Spot(
            name: "Salt River - Blue Point",
            latitude: 33.5456,
            longitude: -111.5687,
            notes: "Best accessed via Blue Point Bridge. Can get crowded but stocked regularly by the state.",
            locationType: "River"
        )
        saltRiver.speciesTags = ["Largemouth Bass", "Bluegill", "Catfish"]
        
        let catch4 = Catch(date: Date().addingTimeInterval(-5 * 24 * 3600), species: "Largemouth Bass", lengthCM: 35.0, weightKG: 1.0, notes: "Caught in a deep pool near the bridge")
        let catch5 = Catch(date: Date().addingTimeInterval(-10 * 24 * 3600), species: "Bluegill", lengthCM: 18.0, weightKG: 0.2, notes: "Lots of small ones, perfect for kids!")
        
        context.insert(catch4)
        context.insert(catch5)
        saltRiver.catches = [catch4, catch5]
        context.insert(saltRiver)
        
        let papagoPond = Spot(
            name: "Papago Park Ponds",
            latitude: 33.4615,
            longitude: -111.9476,
            notes: "Small but reliable ponds for beginners and families. Stocked regularly.",
            locationType: "Pond"
        )
        papagoPond.speciesTags = ["Bluegill", "Catfish", "Sunfish"]
        
        let catch6 = Catch(date: Date().addingTimeInterval(-2 * 24 * 3600), species: "Bluegill", lengthCM: 15.0, weightKG: 0.15, notes: "Caught several, good day.")
        let catch7 = Catch(date: Date().addingTimeInterval(-8 * 24 * 3600), species: "Catfish", lengthCM: 28.0, weightKG: 0.5, notes: nil)
        context.insert(catch6)
        context.insert(catch7)
        papagoPond.catches = [catch6, catch7]
        context.insert(papagoPond)
        
        let kiwanisLake = Spot(
            name: "Kiwanis Recreation Center Lake",
            latitude: 33.4064,
            longitude: -111.9446,
            notes: "Family-friendly fishing spot with easy access. Great for trout in winter months. Has fishing pier and chairs.",
            locationType: "Lake"
        )
        kiwanisLake.speciesTags = ["Rainbow Trout", "Largemouth Bass", "Catfish"]
        
        let catch8 = Catch(date: Date().addingTimeInterval(-12 * 24 * 3600), species: "Rainbow Trout", lengthCM: 28.0, weightKG: 0.4, notes: "Caught with powerbait, stocker fish but fun!")
        let catch9 = Catch(date: Date().addingTimeInterval(-6 * 24 * 3600), species: "Largemouth Bass", lengthCM: 30.0, weightKG: 0.8, notes: "Nice catch off the pier")
        let catch10 = Catch(date: Date().addingTimeInterval(-1 * 24 * 3600), species: "Catfish", lengthCM: 35.0, weightKG: 0.7, notes: nil)
        
        context.insert(catch8)
        context.insert(catch9)
        context.insert(catch10)
        kiwanisLake.catches = [catch8, catch9, catch10]
        context.insert(kiwanisLake)
        
        let canyonLake = Spot(
            name: "Canyon Lake Marina",
            latitude: 33.5425,
            longitude: -111.4350,
            notes: "Mountain lake about 30 min from Tempe. Beautiful scenery, Great for striper bass and trout.",
            locationType: "Lake"
        )
        canyonLake.speciesTags = ["Largemouth Bass", "Smallmouth Bass", "Rainbow Trout"]
        
        let catch11 = Catch(date: Date().addingTimeInterval(-4 * 24 * 3600), species: "Largemouth Bass", lengthCM: 40.0, weightKG: 1.5, notes: "Best catch of the season! Caught near the marina docks")
        let catch12 = Catch(date: Date().addingTimeInterval(-9 * 24 * 3600), species: "Smallmouth Bass", lengthCM: 33.0, weightKG: 0.9, notes: "First smallmouth ever!!!")
        context.insert(catch11)
        context.insert(catch12)
        canyonLake.catches = [catch11, catch12]
        context.insert(canyonLake)
        
        let saguaroLake = Spot(
            name: "Saguaro Lake - Butcher Jones",
            latitude: 33.5733,
            longitude: -111.5189,
            notes: "One of the best bass fishing spots in AZ. Unfortunately, all the fish die in the summer due to PH level changes.",
            locationType: "Lake"
        )
        saguaroLake.speciesTags = ["Largemouth Bass", "Smallmouth Bass", "Rainbow Trout", "Catfish"]
        
        let catch13 = Catch(date: Date().addingTimeInterval(-11 * 24 * 3600), species: "Largemouth Bass", lengthCM: 42.0, weightKG: 1.8, notes: "Monster bass! Personal best. Used topwater lure at dawn.")
        let catch14 = Catch(date: Date().addingTimeInterval(-15 * 24 * 3600), species: "Rainbow Trout", lengthCM: 30.0, weightKG: 0.5, notes: "Winter stocking season, caught several")
        let catch15 = Catch(date: Date().addingTimeInterval(-13 * 24 * 3600), species: "Smallmouth Bass", lengthCM: 35.0, weightKG: 1.1, notes: nil)
        context.insert(catch13)
        context.insert(catch14)
        context.insert(catch15)
        saguaroLake.catches = [catch13, catch14, catch15]
        context.insert(saguaroLake)
        
        save()
        loadSpots()
    }
    
    // update user's location for distance calculations
    func setUserLocation(_ location: CLLocation?) {
        self.userLocation = location
    }

    // Loads all Spot records from SwiftData database
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

    // this func creates and persists a new Spot
    // then refreshes the in-memory list
    func addSpot(name: String, lat: Double, lon: Double, notes: String? = nil, locationType: String = "Lake") {
        guard let context else { return }
        let spot = Spot(name: name, latitude: lat, longitude: lon, notes: notes, locationType: locationType)
        context.insert(spot)
        save()
        loadSpots()
    }
    
    // Add a catch to a spot - when user logs a fish they caught
    func addCatch(to spot: Spot, species: String, lengthCM: Double, weightKG: Double, notes: String? = nil, date: Date = Date()) {
        guard let context else { return }
        let newCatch = Catch(date: date, species: species, lengthCM: lengthCM, weightKG: weightKG, notes: notes)
        spot.catches.append(newCatch)
        // add species to tags if not already there
        if !spot.speciesTags.contains(species) {
            spot.speciesTags.append(species)
        }
        save()
        loadSpots()
    }
    
    // Delete a spot from the database
    func deleteSpot(_ spot: Spot) {
        guard let context else { return }
        context.delete(spot)
        save()
        loadSpots()
    }
    
    // Update a spot's info (name, notes, location type)
    func updateSpot(_ spot: Spot, name: String, notes: String?, locationType: String) {
        guard let context else { return }
        spot.name = name
        spot.notes = notes
        spot.locationType = locationType
        save()
        loadSpots()
    }
    
    // Get distance from user location to spot
    // Returns distance in kilometers
    func distance(to spot: Spot) -> Double? {
        guard let userLoc = userLocation else { return nil }
        let spotLocation = CLLocation(latitude: spot.latitude, longitude: spot.longitude)
        return userLoc.distance(from: spotLocation) / 1000.0 // Convert to km
    }
    
    // Get catch statistics for a spot
    // Returns biggest catch, most common species, and total count
    func catchStats(for spot: Spot) -> (biggest: Catch?, mostCommonSpecies: String?, totalCatches: Int) {
        guard !spot.catches.isEmpty else {
            return (nil, nil, 0)
        }
        
        // find biggest catch by combining weight and length
        let biggest = spot.catches.max { catch1, catch2 in
            (catch1.weightKG * 1000 + catch1.lengthCM) < (catch2.weightKG * 1000 + catch2.lengthCM)
        }
        
        // count how many of each species
        let speciesCounts = Dictionary(grouping: spot.catches, by: { $0.species })
            .mapValues { $0.count }
        let mostCommon = speciesCounts.max(by: { $0.value < $1.value })?.key
        
        return (biggest, mostCommon, spot.catches.count)
    }

    // save pending changes to the SwiftData database
    func save() {
        guard let context else {
            return
        }
        do { try context.save() } catch { print("Save error:", error) }
    }
    
    // Get all unique species from all spots - used for filter dropdown
    var allSpecies: [String] {
        var speciesSet = Set<String>()
        for spot in spots {
            for species in spot.speciesTags {
                speciesSet.insert(species)
            }
            for catchItem in spot.catches {
                speciesSet.insert(catchItem.species)
            }
        }
        return Array(speciesSet).sorted()
    }
    
    // Get all unique location types - used for filter dropdown
    var allLocationTypes: [String] {
        var typesSet = Set<String>()
        for spot in spots {
            typesSet.insert(spot.locationType)
        }
        return Array(typesSet).sorted()
    }

    // Returns filtered spots based on search text, species filter, location type filter, and nearby search
    // This is called by the views to get the list of spots to display
    var filteredSpots: [Spot] {
        var filtered = spots
        
        // Filter by search text (name, notes, species)
        if !searchText.isEmpty {
            filtered = filtered.filter { spot in
                spot.name.localizedCaseInsensitiveContains(searchText) ||
                (spot.notes?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                spot.speciesTags.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                spot.catches.contains { $0.species.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filter by species
        if selectedSpeciesFilter != "All" {
            filtered = filtered.filter { spot in
                spot.speciesTags.contains(selectedSpeciesFilter) || 
                spot.catches.contains { $0.species == selectedSpeciesFilter }
            }
        }
        
        // Filter by location type (Lake, River, etc.)
        if selectedLocationTypeFilter != "All" {
            filtered = filtered.filter {
                $0.locationType == selectedLocationTypeFilter
            }
        }
        
        // Filter by nearby (within 50km) - uses GPS distance
        if searchNearby, let userLoc = userLocation {
            filtered = filtered.filter { spot in
                let spotLocation = CLLocation(latitude: spot.latitude, longitude: spot.longitude)
                let distance = userLoc.distance(from: spotLocation) / 1000.0 // Convert to km
                return distance <= 50.0 // Within 50km
            }
        }
        
        // Sort the filtered results based on selected sort option
        filtered = sortSpots(filtered)
        
        return filtered
    }
    
    // Helper function to sort spots based on the selected option
    private func sortSpots(_ spots: [Spot]) -> [Spot] {
        switch sortOption {
        case .name:
            return spots.sorted { $0.name < $1.name }
            
        case .distance:
            // sort by distance from user (closest first)
            guard let userLoc = userLocation else { return spots }
            return spots.sorted { spot1, spot2 in
                let loc1 = CLLocation(latitude: spot1.latitude, longitude: spot1.longitude)
                let loc2 = CLLocation(latitude: spot2.latitude, longitude: spot2.longitude)
                let dist1 = userLoc.distance(from: loc1)
                let dist2 = userLoc.distance(from: loc2)
                return dist1 < dist2
            }
            
        case .catches:
            // sort by most catches first
            return spots.sorted { $0.catches.count > $1.catches.count }
            
        case .recent:
            // sort by most recently caught fish
            return spots.sorted { spot1, spot2 in
                let recent1 = spot1.catches.max(by: { $0.date < $1.date })?.date ?? Date.distantPast
                let recent2 = spot2.catches.max(by: { $0.date < $1.date })?.date ?? Date.distantPast
                return recent1 > recent2
            }
        }
    }
}
