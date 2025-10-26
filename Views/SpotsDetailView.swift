//
//  SpotsDetailView.swift
//  AnglerSpots
//
//  Created by Luan Thien Nguyen on 10/26/25.
//

import SwiftUI

struct SpotDetailView: View {
    let spot: Spot?
    @State private var temp: String = "—"
    @State private var isLoading = false
    private let ws = WeatherService()

    var body: some View {
        if let s = spot {
            List {
                Section("Info") {
                    Text(s.name).bold()
                    Text("Lat: \(s.latitude, specifier: "%.4f"), Lon: \(s.longitude, specifier: "%.4f")")
                    if let notes = s.notes, !notes.isEmpty {
                        Text("Notes: \(notes)")
                    }
                }

                Section("Conditions") {
                    HStack {
                        Text("Temperature")
                        Spacer()
                        Text(temp)
                    }
                }

                Section("Catches") {
                    if s.catches.isEmpty {
                        Text("No catches yet")
                    } else {
                        ForEach(s.catches, id: \.date) { c in
                            VStack(alignment: .leading) {
                                Text(c.species).bold()
                                Text(c.date.formatted())
                                Text("Len \(Int(c.lengthCM)) cm  Wt \(String(format: "%.1f", c.weightKG)) kg")
                            }
                        }
                    }
                }
            }
            .task {
                guard !isLoading else { return }
                isLoading = true
                if let t = try? await ws.fetchCurrentTemp(lat: s.latitude, lon: s.longitude) {
                    temp = "\(Int(round(t))) °C"
                }
                isLoading = false
            }
            .navigationTitle("Spot Details")
        } else {
            Text("No spot selected")
        }
    }
}
