//
//  Item.swift
//  10000hours
//
//  Created by Nathan Davis on 8/30/25.
//

import Foundation
import SwiftData

@Model
class Item: Identifiable, ObservableObject {
    var id: UUID = UUID()
    var name: String
    var startTime: Int   // all time ever
    var todayMinutes: Int   // only today's tracked time
    var order: Int
    
    init(name: String, startTime: Int = 0, todayMinutes: Int = 0, order: Int = 0) {
        self.name = name
        self.startTime = startTime
        self.todayMinutes = todayMinutes
        self.order = order
    }
}
