// Luan Nguyen
// CSE335
// Phase II
//
//  SpotsListScreen.swift
//  AnglerSpots


import SwiftUI

// SpotsListScreen
struct SpotsListScreen: View {
    @ObservedObject var vm: SpotsViewModel
    
    @StateObject private var loc = LocationManager()  // for getting user location
    @State private var showAddSpot = false  // show add spot sheet

    var body: some View {
        Group {
            // show empty search state if search has no results
            if vm.filteredSpots.isEmpty && !vm.searchText.isEmpty {
                emptySearchState
            } else if vm.spots.isEmpty {
                // show empty state if no spots exist at all
                emptyState
            } else {
                // show list of spots
                List {
                    ForEach(vm.filteredSpots, id: \.id) { spot in
                        NavigationLink {
                            SpotDetailView(spot: spot, vm: vm)
                        } label: {
                            SpotRowView(spot: spot, vm: vm)  // custom row view for each spot
                        }
                        
                        // swipe left to delete a spot
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                vm.deleteSpot(spot)  // delete spot from database
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .searchable(text: $vm.searchText, prompt: "Search spots, notes, or species...")
        .navigationTitle("Fishing Spots")
        .toolbar {
            // add button in toolbar
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showAddSpot = true  // show add spot form
                    } label: {
                        Label("Add New Spot", systemImage: "plus.circle")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showAddSpot) {
            AddSpotView(vm: vm, locationManager: loc)
        }
        // filters at bottom of screen
        .safeAreaInset(edge: .bottom) {
            filtersView
        }
        .onAppear {
            loc.request()  // request location permission
            if let location = loc.currentLocation {
                vm.setUserLocation(location)
            }
        }
        .onChange(of: loc.currentLocation) { oldValue, newValue in
            // update location when GPS updates
            if let location = newValue {
                vm.setUserLocation(location)
            }
        }
    }
    
    // empty state, shows when there are no spots yet
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "map.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.6))
            Text("No Fishing Spots Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Tap the + button to add your first fishing spot")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button {
                showAddSpot = true
            } label: {
                Label("Add Spot", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // empty search state
    private var emptySearchState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No Results Found")
                .font(.title3)
                .fontWeight(.medium)
            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // shows sort and filter options at bottom
    private var filtersView: some View {
        VStack(spacing: 12) {
            // Sort options
            HStack {
                Text("Sort by:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Picker("Sort", selection: $vm.sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.menu)
                Spacer()
            }
            .padding(.horizontal)
            
            // Nearby search toggle
            Toggle("Show spots within 50km", isOn: $vm.searchNearby)
                .padding(.horizontal)
            
            // species filter
            if !vm.allSpecies.isEmpty {
                speciesFilter
            }
            
            // location type filter
            if !vm.allLocationTypes.isEmpty {
                locationTypeFilter
            }
        }
        .padding(.vertical, 12)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    // species filter
    private var speciesFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["All"] + vm.allSpecies, id: \.self) { species in
                    Button {
                        vm.selectedSpeciesFilter = species  // set filter
                    } label: {
                        Text(species)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(vm.selectedSpeciesFilter == species ? Color.blue : Color(UIColor.systemGray5))
                            .foregroundColor(vm.selectedSpeciesFilter == species ? .white : .primary)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // location type filter
    private var locationTypeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["All"] + vm.allLocationTypes, id: \.self) { type in
                    Button {
                        vm.selectedLocationTypeFilter = type  // set filter
                    } label: {
                        Text(type)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(vm.selectedLocationTypeFilter == type ? Color.green : Color(UIColor.systemGray5))
                            .foregroundColor(vm.selectedLocationTypeFilter == type ? .white : .primary)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// Enhanced spot row view
// shows each spot in the list
struct SpotRowView: View {
    let spot: Spot
    @ObservedObject var vm: SpotsViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Location type icon
            locationIcon
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                // spot name and distance
                HStack {
                    Text(spot.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    // show distance if we have user location
                    if let distance = vm.distance(to: spot) {
                        Text(formatDistance(distance))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // location type and catch count
                HStack(spacing: 8) {
                    Label(spot.locationType, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // show catch count if there are catches
                    if !spot.catches.isEmpty {
                        Label("\(spot.catches.count)", systemImage: "fish.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                // species tags
                if !spot.speciesTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(spot.speciesTags.prefix(3), id: \.self) { species in
                                Text(species)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                            if spot.speciesTags.count > 3 {
                                Text("+\(spot.speciesTags.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // get icon based on location type
    private var locationIcon: Image {
        switch spot.locationType {
        case "Lake": return Image(systemName: "drop.fill")
        case "River": return Image(systemName: "waveform.path")
        case "Ocean": return Image(systemName: "water.waves")
        case "Pond": return Image(systemName: "circle.fill")
        default: return Image(systemName: "location.fill")
        }
    }
    
    // func to format distance
    private func formatDistance(_ km: Double) -> String {
        if km < 1 {
            return String(format: "%.0fm", km * 1000)
        } else {
            return String(format: "%.1fkm", km)
        }
    }
}
