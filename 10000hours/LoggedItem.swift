//
//  LoggedItem.swift
//  10000hours
//
//  Created by Nathan Davis on 8/30/25.
//

import Foundation
import SwiftData

@Model
class LoggedItem: Identifiable, ObservableObject {
    var id: UUID = UUID()
    var itemName: String
    var minutes: Int
    var activityDescription: String
    var date: Date
    
    init(itemName: String, minutes: Int, activityDescription: String) {
        self.itemName = itemName
        self.minutes = minutes
        self.activityDescription = activityDescription
        self.date = Date()
    }
}

