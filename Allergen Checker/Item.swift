//
//  Item.swift
//  Allergen Checker
//
//  Created by Marc Thomas on 25/04/2026.
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
