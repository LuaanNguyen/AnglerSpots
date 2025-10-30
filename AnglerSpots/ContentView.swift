// Luan Nguyen
// CSE335
// Phase I
//  ContentView.swift
//  AnglerSpots


import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var vm = SpotsViewModel()
    
    var body: some View {
        NavigationStack {
            if vm.isInitialized {
                TabView {
                    // map tab for browsing spots on a map
                    MapScreen(vm: vm)
                        .tabItem { Label("Map", systemImage: "map") }

                    // list tab for browsing spots in a list
                    SpotsListScreen(vm: vm)
                        .tabItem { Label("List", systemImage: "list.bullet") }
                }
            } else {
                // wait until SwiftData context is ready and then inject it into the view model.
                ProgressView("Loading…")
                    .task {
                        vm.setContext(context)
                    }
            }
        }
    }
}

#Preview {
    // in-memory store for previews so no on-disk persistence is used.
    let container = try! ModelContainer(
        for: Spot.self, Catch.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    ContentView()
        .modelContainer(container)
}
