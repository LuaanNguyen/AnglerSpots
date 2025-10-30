// Luan Nguyen
// CSE335
// Phase I
//
//  MapScreen.swift
//  AnglerSpots
//
//  Map-based browsing UI for fishing spots.


import SwiftUI
import MapKit
import SwiftData

struct MapScreen: View {
    @ObservedObject var vm: SpotsViewModel
    @StateObject private var loc = LocationManager()   // Manages location permission and current location
    @State private var camera = MapCameraPosition.userLocation(fallback: .automatic)

    var body: some View {
        VStack {
            Map(position: $camera) {
                // Show an annotation for each filtered spot.
                ForEach(vm.filteredSpots, id: \.id) { spot in
                    Annotation(spot.name, coordinate: spot.coordinate) {
                        Button {
                            vm.selectedSpot = spot
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                    }
                }
                // Display the user's current location on the map
                UserAnnotation()
            }
            .onAppear { loc.request() } // Request location permission when the map appears
            .frame(minHeight: 300)

            // (DEMO for now)
            HStack {
                TextField("Search spots", text: $vm.searchText)
                    .textFieldStyle(.roundedBorder)
                Button("Add Demo") {
                    let lat = loc.currentLocation?.coordinate.latitude ?? 33.4255
                    let lon = loc.currentLocation?.coordinate.longitude ?? -111.94
                    vm.addSpot(name: "Tempe Town Lake", lat: lat, lon: lon, notes: "Shore access")
                }
            }
            .padding()

            // detail view when a spot is selected.
            NavigationLink(
                destination: SpotDetailView(spot: vm.selectedSpot),
                isActive: Binding(
                    get: { vm.selectedSpot != nil },
                    set: { if !$0 { vm.selectedSpot = nil } })
            ) { EmptyView() }
        }
        .navigationTitle("Fishing Map")
    }
}
