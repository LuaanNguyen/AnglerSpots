// Luan Nguyen
// CSE335
// Phase II
//
//  AddCatchView.swift
//  AnglerSpots

import SwiftUI

// Form to log a fish catch at a spot
struct AddCatchView: View {
    @ObservedObject var vm: SpotsViewModel
    let spot: Spot
    @Environment(\.dismiss) private var dismiss
    
    @State private var species: String = ""  // fish species (e.g., "Bass")
    @State private var lengthCM: String = ""  // length in centimeters
    @State private var weightKG: String = ""  // weight (kg)
    
    @State private var notes: String = ""  // (optional) notes
    @State private var date: Date = Date()  // date caught (defaulted to today)
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Catch Information") {
                    TextField("Species", text: $species)  // required
                    TextField("Length (cm)", text: $lengthCM)
                        .keyboardType(.decimalPad)
                    TextField("Weight (kg)", text: $weightKG)
                        .keyboardType(.decimalPad)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section {
                    // Add button
                    Button {
                        addCatch()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Add Catch", systemImage: "fish.fill")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!canAddCatch)  // disable if form invalid
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .navigationTitle("Add Catch")
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
    private var canAddCatch: Bool {
        guard !species.isEmpty else {
            return false
        }  // species required
        guard !lengthCM.isEmpty, Double(lengthCM) != nil else {
            return false
        }  // valid length
        guard !weightKG.isEmpty, Double(weightKG) != nil else {
            return false
        }  // valid weight
        return true
    }
    
    // add catch to spot -
    private func addCatch() {
        // convert strings to doubles
        guard let length = Double(lengthCM),
              let weight = Double(weightKG) else {
            return
        }
        
        // call view model to add catch to SwiftData
        vm.addCatch(
            to: spot,
            species: species,
            lengthCM: length,
            weightKG: weight,
            notes: notes.isEmpty ? nil : notes,  // nil if empty
            date: date
        )
        
        dismiss() 
    }
}

