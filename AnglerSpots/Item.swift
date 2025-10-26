//
//  Item.swift
//  AnglerSpots
//
//  Created by Luan Thien Nguyen on 10/26/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
