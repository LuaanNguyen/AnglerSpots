//
//  MapScreen.swift
//  AnglerSpots
//
//  Created by Luan Thien Nguyen on 10/26/25.
//

import SwiftUI
import MapKit
import SwiftData

struct MapScreen: View {
    @ObservedObject var vm: SpotsViewModel
    @StateObject private var loc = LocationManager()
    @State private var camera = MapCameraPosition.userLocation(fallback: .automatic)

    var body: some View {
        VStack {
            Map(position: $camera) {
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
                UserAnnotation()
            }
            .onAppear { loc.request() }
            .frame(minHeight: 300)

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
