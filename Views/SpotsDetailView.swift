// Luan Nguyen
// CSE335
// Phase II
//
//  SpotsDetailView.swift
//  AnglerSpots


import SwiftUI

// shows detailed info about a fishing spot
// This is a sheet that appears when user taps a spot on map or in list
struct SpotDetailView: View {
    let spot: Spot?
    @ObservedObject var vm: SpotsViewModel
    
    @State private var temp: String = "—"  // temperature from weather API
    @State private var sunrise: String = "—"  // sunrise time from weather API
    @State private var sunset: String = "—"  // sunset time from weather API
    @State private var isLoading = false  // loading state
    
    @State private var showAddCatch = false  // show add catch sheet
    @State private var showEditSpot = false  // show edit spot sheet
    @State private var showDeleteConfirmation = false  // show delete confirmation
    
    private let ws = WeatherService()  // Weather API
    
    // computed property to get catch statistics (biggest, most common species, total)
    private var stats: (biggest: Catch?, mostCommonSpecies: String?, totalCatches: Int) {
        guard let s = spot else {
            return (nil, nil, 0)
        }
        return vm.catchStats(for: s)
    }

    var body: some View {
        if let s = spot {
            List {
                Section {
                    HStack(spacing: 16) {
                        locationIcon
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                            .frame(width: 60, height: 60)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(s.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Label(s.locationType, systemImage: "location.fill")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if let distance = vm.distance(to: s) {
                                Label(formatDistance(distance), systemImage: "location.circle")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Statistics section
                if !s.catches.isEmpty {
                    Section("Statistics") {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total Catches")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(stats.totalCatches)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            if let species = stats.mostCommonSpecies {
                                VStack(alignment: .trailing) {
                                    Text("Most Common")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(species)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            if let biggest = stats.biggest {
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Biggest Catch")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(String(format: "%.1f", biggest.weightKG)) kg")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }

                Section("Information") {
                    if let notes = s.notes, !notes.isEmpty {
                        HStack(alignment: .top) {
                            Text("Notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(notes)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    HStack {
                        Text("Coordinates")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(s.latitude, specifier: "%.4f"), \(s.longitude, specifier: "%.4f")")
                            .font(.caption)
                            .textSelection(.enabled)
                    }
                    
                    if !s.speciesTags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Species Found")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            FlowLayout(items: s.speciesTags) { species in
                                Text(species)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                Section {
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        HStack {
                            Label("Temperature", systemImage: "thermometer")
                            Spacer()
                            Text(temp)
                                .fontWeight(.medium)
                        }
                        HStack {
                            Label("Sunrise", systemImage: "sunrise.fill")
                                .foregroundColor(.orange)
                            Spacer()
                            Text(sunrise)
                                .fontWeight(.medium)
                        }
                        HStack {
                            Label("Sunset", systemImage: "sunset.fill")
                                .foregroundColor(.orange)
                            Spacer()
                            Text(sunset)
                                .fontWeight(.medium)
                        }
                    }
                } header: {
                    Text("Weather Conditions")
                } footer: {
                    Text("Current weather data from Open-Meteo")
                        .font(.caption2)
                }

                Section {
                    if s.catches.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "fish.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary.opacity(0.5))
                            Text("No catches yet")
                                .foregroundColor(.secondary)
                            Text("Start logging your fishing success!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        ForEach(Array(s.catches.sorted { $0.date > $1.date }.enumerated()), id: \.element.date) { index, c in
                            CatchRowView(catchItem: c, index: index + 1)
                        }
                    }
                    
                    Button {
                        showAddCatch = true
                    } label: {
                        Label("Add Catch", systemImage: "plus.circle.fill")
                            .fontWeight(.medium)
                    }
                } header: {
                    Text("Catches")
                } footer: {
                    if !s.catches.isEmpty {
                        Text("Total: \(s.catches.count) catch\(s.catches.count == 1 ? "" : "es")")
                    }
                }
            }
            .navigationTitle("Spot Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showEditSpot = true
                        } label: {
                            Label("Edit Spot", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete Spot", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showAddCatch) {
                AddCatchView(vm: vm, spot: s)
            }
            .sheet(isPresented: $showEditSpot) {
                EditSpotView(vm: vm, spot: s)
            }
            .alert("Delete Spot", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    vm.deleteSpot(s)
                }
            } message: {
                Text("Are you sure you want to delete \"\(s.name)\"? This action cannot be undone.")
            }
            // Lazy-load current weather once when the view appears
            // This fetches weather from the API when the detail view opens
            .task {
                guard !isLoading else { return }
                isLoading = true
                // call weather API with spot coordinates
                if let weather = try? await ws.fetchWeatherData(lat: s.latitude, lon: s.longitude) {
                    // format temperature, sunrise time, sunset
                    if let t = weather.temperature {
                        temp = "\(Int(round(t))) °C"
                    }

                    if let sr = weather.sunrise {
                        sunrise = formatTime(sr)
                    }
                    if let ss = weather.sunset {
                        sunset = formatTime(ss)
                    }
                }
                isLoading = false
            }
        } else {
            // show empty state if no spot selected
            ContentUnavailableView("No Spot Selected", systemImage: "mappin.slash", description: Text("Select a spot to view details"))
        }
    }
    
    // helper to get icon based on location type
    private var locationIcon: Image {
        guard let s = spot else { return Image(systemName: "location.fill") }
        switch s.locationType {
        case "Lake": return Image(systemName: "drop.fill")
        case "River": return Image(systemName: "waveform.path")
        case "Ocean": return Image(systemName: "water.waves")
        case "Pond": return Image(systemName: "circle.fill")
        default: return Image(systemName: "location.fill")
        }
    }
    
    // format distance
    // This shows in meters if < 1km, else kilometers
    private func formatDistance(_ km: Double) -> String {
        if km < 1 {
            return String(format: "%.0f m", km * 1000)
        } else {
            return String(format: "%.1f km", km)
        }
    }
    
    // format time string from API (ISO format) to readable time (e.g., "6:30 AM")
    // "2024-01-01T06:30:00Z" to "6:30 AM"
    private func formatTime(_ timeString: String) -> String {
       
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = formatter.date(from: String(timeString.prefix(19))) {
            let displayFormatter = DateFormatter()
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return timeString
    }
}

// Enhanced catch row view shows a single catch in the list
struct CatchRowView: View {
    let catchItem: Catch
    let index: Int  // catch # (1, 2, 3, etc.)
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(index)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                // species and date
                HStack {
                    Text(catchItem.species)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    // formatted date
                    Text(catchItem.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // length and weight
                HStack(spacing: 16) {
                    Label("\(Int(catchItem.lengthCM)) cm", systemImage: "ruler")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(String(format: "%.1f", catchItem.weightKG)) kg", systemImage: "scalemass")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // notes
                if let notes = catchItem.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                        .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// Flow layout for tags
// Used to display species tags in a nice flowing layout
struct FlowLayout: View {
    let items: [String]
    let content: (String) -> AnyView
    
    init(items: [String], @ViewBuilder content: @escaping (String) -> some View) {
        self.items = items
        self.content = { AnyView(content($0)) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items.chunked(into: 4), id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { item in
                        content(item)  // render each item
                    }
                    Spacer()
                }
            }
        }
    }
}

// extension to split array into chunks
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// form to edit an existing spot
struct EditSpotView: View {
    @ObservedObject var vm: SpotsViewModel
    let spot: Spot  // the spot being edited
    
    @Environment(\.dismiss) private var dismiss
    
    
    //pre-filled from spot
    @State private var name: String
    @State private var notes: String
    @State private var locationType: String
    
    let locationTypes = ["Lake", "River", "Ocean", "Pond", "Stream", "Reservoir"]
    
    init(vm: SpotsViewModel, spot: Spot) {
        self.vm = vm
        self.spot = spot
        _name = State(initialValue: spot.name)
        _notes = State(initialValue: spot.notes ?? "")
        _locationType = State(initialValue: spot.locationType)
    }
    
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
                
                Section {
                    // Save button( disabled if name is empty)
                    Button("Save Changes") {
                        vm.updateSpot(spot, name: name, notes: notes.isEmpty ? nil : notes, locationType: locationType)
                        
                        dismiss()
                    }
                    .disabled(name.isEmpty)  // must have a name
                }
            }
            .navigationTitle("Edit Spot")
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
}
