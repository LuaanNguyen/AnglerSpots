
//
//  Untitled.swift
//  AnglerSpots
//
//  Created by Luan Thien Nguyen on 10/26/25.
//

import SwiftUI

struct SpotsListScreen: View {
    @ObservedObject var vm: SpotsViewModel

    var body: some View {
        List(vm.filteredSpots, id: \.id) { spot in
            NavigationLink(spot.name) {
                SpotDetailView(spot: spot)
            }
        }
        .searchable(text: $vm.searchText)
        .navigationTitle("All Spots")
    }
}
