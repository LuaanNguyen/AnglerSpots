//
//  ContentView.swift
//  AnglerSpots
//
//  Created by Luan Thien Nguyen on 10/26/25.
//


import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var vm = SpotsViewModel()  

    var body: some View {
        NavigationStack {
            if vm.isInitialized {
                TabView {
                    MapScreen(vm: vm)
                        .tabItem { Label("Map", systemImage: "map") }

                    SpotsListScreen(vm: vm)
                        .tabItem { Label("List", systemImage: "list.bullet") }
                }
            } else {
                // Wait until SwiftData context is ready
                ProgressView("Loading…")
                    .task {
                        vm.setContext(context)
                    }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Spot.self, Catch.self,            
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    ContentView()
        .modelContainer(container)
}
