// Luan Nguyen
// CSE335
// Phase II
//  ContentView.swift
//  AnglerSpots

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context  // SwiftData
    
    @StateObject private var vm = SpotsViewModel()
    
    var body: some View {
        NavigationStack {
            if vm.isInitialized {
                TabView {
                    // map tab: browsing spots on a map
                    MapScreen(vm: vm)
                        .tabItem { Label("Map", systemImage: "map") }

                    // list tab: browsing spots in a list
                    SpotsListScreen(vm: vm)
                        .tabItem { Label("List", systemImage: "list.bullet") }
                    
                    //TODO: maybe add loading screen like fishbrains
                }
            } else {
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
