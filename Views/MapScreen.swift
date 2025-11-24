// Luan Nguyen
// CSE335
// Phase II
//
//  MapScreen.swift
//  AnglerSpots
//
//  Map-based browsing UI for fishing spots.


import SwiftUI
import MapKit
import SwiftData

// MapScreen - shows fishing spots on a map
// This is one of the two main tabs in the app
struct MapScreen: View {
    @ObservedObject var vm: SpotsViewModel  // view model for business logic
    @StateObject private var loc = LocationManager()   // Manages location permission and current location
    @State private var camera = MapCameraPosition.automatic  // map camera position
    @State private var showAddSpot = false  // show add spot sheet
    @State private var currentTemperature: String? = nil  // current temp at user location
    @State private var isLoadingTemperature = false  // loading state for weather
    private let weatherService = WeatherService()  // service to fetch weather

    var body: some View {
        VStack(spacing: 0) {
            // The map itself - uses MapKit
            Map(position: $camera) {
                // Show an annotation for each filtered spot.
                // Each spot shows as a pin on the map
                ForEach(vm.filteredSpots, id: \.id) { spot in
                    Annotation(spot.name, coordinate: spot.coordinate) {
                        Button {
                            vm.selectedSpot = spot  // select spot when tapped
                        } label: {
                            VStack(spacing: 2) {
                                // icon based on location type (Lake, River, etc.)
                                Image(systemName: annotationIcon(for: spot.locationType))
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(annotationColor(for: spot.locationType))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                
                                // show catch count badge if there are catches
                                if !spot.catches.isEmpty {
                                    Text("\(spot.catches.count)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.orange)
                                        .clipShape(Capsule())
                                        .offset(y: -8)
                                }
                            }
                            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                        }
                    }
                }
                // Display the user's current location on the map (blue dot)
                if loc.currentLocation != nil {
                    UserAnnotation()
                }
            }
            .onAppear {
                loc.request()
                
                // If we have spots, center map to show them
                if !vm.spots.isEmpty {
                    let coordinates = vm.spots.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                    let minLat = coordinates.map { $0.latitude }.min() ?? 33.4
                    let maxLat = coordinates.map { $0.latitude }.max() ?? 33.6
                    let minLon = coordinates.map { $0.longitude }.min() ?? -111.9
                    let maxLon = coordinates.map { $0.longitude }.max() ?? -111.4
                    
                    let centerLat = (minLat + maxLat) / 2
                    let centerLon = (minLon + maxLon) / 2
                    let latDelta = max((maxLat - minLat) * 1.5, 0.05)
                    let lonDelta = max((maxLon - minLon) * 1.5, 0.05)
                    
                    camera = .region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                        span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                    ))
                } else if let location = loc.currentLocation {
                    vm.setUserLocation(location)
                    camera = .region(MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    ))
                } else {
                    // Default to Tempe, Arizona if no location available
                    camera = .region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: 33.4278, longitude: -111.9376),
                        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                    ))
                }
            }
            .onChange(of: loc.currentLocation) { oldValue, newValue in
                if let location = newValue {
                    vm.setUserLocation(location)
                    // Only center on user location if there are no spots
                    if vm.spots.isEmpty {
                        camera = .region(MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        ))
                    }
                }
            }
            .mapControls {
                // Removed MapUserLocationButton because it centers on SF in simulator
                // Use custom button below instead
                MapCompass()
            }
            .overlay(alignment: .topTrailing) {
                // Custom button to center on all spots instead of user location
                if !vm.spots.isEmpty {
                    Button {
                        centerMapOnSpots()
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding()
                }
            }
            .frame(minHeight: 400)

            // Search and add controls at the bottom
            VStack(spacing: 12) {
                // Search bar and add button
                HStack(spacing: 12) {
                    TextField("Search spots...", text: $vm.searchText)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.search)
                    
                    // Add new spot button
                    Button {
                        showAddSpot = true  // show add spot form
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(loc.currentLocation == nil && loc.authorizationStatus != .authorizedWhenInUse)
                }
                .padding(.horizontal)
                
                // Current location temperature display
                // Shows temp at user's current location
                if let location = loc.currentLocation {
                    HStack {
                        CurrentTemperatureCard(
                            temperature: currentTemperature,
                            isLoading: isLoadingTemperature
                        )
                        Spacer()
                    }
                    .padding(.horizontal)
                    .onAppear {
                        // fetch weather when view appears
                        fetchCurrentTemperature(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                    }
                    .onChange(of: loc.currentLocation) { oldValue, newValue in
                        // update weather when location changes
                        if let newLocation = newValue {
                            fetchCurrentTemperature(lat: newLocation.coordinate.latitude, lon: newLocation.coordinate.longitude)
                        }
                    }
                }
                
                // Filter chips - show active filters
                if !vm.searchText.isEmpty || vm.selectedSpeciesFilter != "All" || vm.selectedLocationTypeFilter != "All" || vm.searchNearby {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if vm.searchNearby {
                                FilterChip(text: "Within 50km", color: .green) {
                                    vm.searchNearby = false
                                }
                            }
                            if vm.selectedSpeciesFilter != "All" {
                                FilterChip(text: vm.selectedSpeciesFilter, color: .blue) {
                                    vm.selectedSpeciesFilter = "All"
                                }
                            }
                            if vm.selectedLocationTypeFilter != "All" {
                                FilterChip(text: vm.selectedLocationTypeFilter, color: .orange) {
                                    vm.selectedLocationTypeFilter = "All"
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
        }
        .navigationTitle("Fishing Map")
        // sheet to add new spot
        .sheet(isPresented: $showAddSpot) {
            AddSpotView(vm: vm, locationManager: loc)
        }
        // sheet to show spot details when tapped
        .sheet(item: $vm.selectedSpot) { spot in
            NavigationStack {
                SpotDetailView(spot: spot, vm: vm)
            }
        }
        .overlay(alignment: .topTrailing) {
            // show message if no spots match filters
            if vm.filteredSpots.isEmpty && !vm.spots.isEmpty {
                VStack {
                    Image(systemName: "mappin.slash")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Text("No spots match filters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding()
            }
        }
    }
    
    // center map on all spots
    private func centerMapOnSpots() {
        guard !vm.spots.isEmpty else { return }
        
        let coordinates = vm.spots.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        let minLat = coordinates.map { $0.latitude }.min() ?? 33.4
        let maxLat = coordinates.map { $0.latitude }.max() ?? 33.6
        let minLon = coordinates.map { $0.longitude }.min() ?? -111.9
        let maxLon = coordinates.map { $0.longitude }.max() ?? -111.4
        
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        let latDelta = max((maxLat - minLat) * 1.5, 0.05)
        let lonDelta = max((maxLon - minLon) * 1.5, 0.05)
        
        camera = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        ))
    }
    
    // helper function to get icon for location type
    private func annotationIcon(for locationType: String) -> String {
        switch locationType {
        case "Lake": return "drop.fill"
        case "River": return "waveform.path"
        case "Ocean": return "water.waves"
        case "Pond": return "circle.fill"
        default: return "mappin.circle.fill"
        }
    }
    
    // helper function to get color for location type
    private func annotationColor(for locationType: String) -> Color {
        switch locationType {
        case "Lake": return .blue
        case "River": return .cyan
        case "Ocean": return .indigo
        case "Pond": return .teal
        default: return .red
        }
    }
    
    // fetch current temperature at given coordinates
    // uses WeatherService to call the API
    private func fetchCurrentTemperature(lat: Double, lon: Double) {
        guard !isLoadingTemperature else { return }
        isLoadingTemperature = true
        
        Task {
            do {
                // call weather API
                if let temp = try await weatherService.fetchCurrentTemp(lat: lat, lon: lon) {
                    await MainActor.run {
                        currentTemperature = "\(Int(round(temp)))°C"  // format temp
                        isLoadingTemperature = false
                    }
                } else {
                    await MainActor.run {
                        currentTemperature = "—"
                        isLoadingTemperature = false
                    }
                }
            } catch {
                // handle error - just show dash
                await MainActor.run {
                    currentTemperature = "—"
                    isLoadingTemperature = false
                }
            }
        }
    }
}

// Current temperature card overlay
// Shows the temperature at user's current location
struct CurrentTemperatureCard: View {
    let temperature: String?  // temp string to display
    let isLoading: Bool  // loading state
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon container with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                if isLoading {
                    // show loading spinner while fetching
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(.orange)
                } else {
                    // thermometer icon with gradient
                    Image(systemName: "thermometer.sun.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // temperature text
                if let temp = temperature {
                    Text(temp)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                } else if !isLoading {
                    Text("—")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                
                // location label
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                    Text("Your Location")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)  // frosted glass effect
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        )
    }
}

// Filter chip - shows active filter with X button to remove
struct FilterChip: View {
    let text: String  // filter text
    let color: Color  // chip color
    let onDismiss: () -> Void  // callback when X is tapped
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
            Button {
                onDismiss()  // remove filter when X tapped
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color)
        .cornerRadius(16)
    }
}
