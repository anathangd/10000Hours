//
//  _0000hoursApp.swift
//  10000hours
//
//  Created by Nathan Davis on 8/30/25.
//

import SwiftUI
import SwiftData

@main
struct _0000hoursApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            LoggedItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
