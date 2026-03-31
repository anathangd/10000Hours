//
//  Item.swift
//  10000hours
//
//  Created by Nathan Davis on 8/30/25.
//

import Foundation
import SwiftUI
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

extension String {
    func limited(to maxLength: Int) -> String {
        String(prefix(maxLength))
    }
}

extension Binding where Value == String {
    func limited(to maxLength: Int) -> Binding<String> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0.limited(to: maxLength) }
        )
    }
}
