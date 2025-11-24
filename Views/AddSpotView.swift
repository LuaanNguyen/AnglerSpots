// Luan Nguyen
// CSE335
// Phase II
//
//  AddSpotView.swift
//  AnglerSpots

import SwiftUI
import CoreLocation

// AddSpotView
// form to add a new fishing spot
struct AddSpotView: View {
    @ObservedObject var vm: SpotsViewModel
    @ObservedObject var locationManager: LocationManager  // getting GPS location
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var locationType: String = "Lake"
    @State private var useCurrentLocation: Bool = true
    
    @State private var customLat: String = ""
    @State private var customLon: String = ""
    
    let locationTypes = ["Lake", "River", "Ocean", "Pond", "Stream", "Reservoir"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Spot Information") {
                    TextField("Spot Name", text: $name)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Location Type", selection: $locationType) {
                        ForEach(locationTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                }
                
                Section("Location") {
                    // toggle to use GPS or manual coordinates
                    Toggle("Use Current Location", isOn: $useCurrentLocation)
                    
                    if !useCurrentLocation {
                        // show text fields for manual entry
                        TextField("Latitude", text: $customLat)
                            .keyboardType(.numbersAndPunctuation)
                        TextField("Longitude", text: $customLon)
                            .keyboardType(.numbersAndPunctuation)
                    } else {
                        // show current GPS coordinates
                        if let loc = locationManager.currentLocation {
                            Text("Lat: \(loc.coordinate.latitude, specifier: "%.6f")")
                            Text("Lon: \(loc.coordinate.longitude, specifier: "%.6f")")
                        } else {
                            Text("Getting location...")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section {
                    // Add button
                    Button {
                        addSpot()  // save spot to database
                    } label: {
                        HStack {
                            Spacer()
                            Label("Add Spot", systemImage: "plus.circle.fill")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!canAddSpot)  // disable if form invalid
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .navigationTitle("Add New Spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()  // close without saving
                    }
                }
            }
        }
    }
    
    // check if form is valid
    private var canAddSpot: Bool {
        guard !name.isEmpty else {
            return false
        }  // name must not be empty
        
        if useCurrentLocation {
            return locationManager.currentLocation != nil  // need GPS location
        } else {
            return Double(customLat) != nil && Double(customLon) != nil  // need valid lat/lon
        }
    }
    
    // add spot to database
    private func addSpot() {
        let lat: Double
        let lon: Double
        
        if useCurrentLocation {
            // use GPS coordinates
            guard let loc = locationManager.currentLocation else { return }
            lat = loc.coordinate.latitude
            lon = loc.coordinate.longitude
        } else {
            // use manual coordinates
            guard let latVal = Double(customLat),
                  let lonVal = Double(customLon) else { return }
            lat = latVal
            lon = lonVal
        }
        
        // call view model to add spot abd saves to SwiftData
        vm.addSpot(
            name: name,
            lat: lat,
            lon: lon,
            notes: notes.isEmpty ? nil : notes,  
            locationType: locationType
        )
        
        dismiss()
    }
}

