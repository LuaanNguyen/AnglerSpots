// Luan Nguyen
// CSE335
// Phase I
//
//  Item.swift
//  AnglerSpots

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
