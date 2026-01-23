//
//  ItemView.swift
//  10000hours
//
//  Created by Nathan Davis on 8/30/25.
//

import SwiftUI
import SwiftData

struct ItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LoggedItem.date, order: .reverse) private var allLogs: [LoggedItem]
    let item: Item
    let isActive: Bool
    let onPlayStop: (Item) -> Void
    
    private var todayMinutes: Int {
        let calendar = Calendar.current
        let todayLogs = allLogs.filter { log in
            log.itemName == item.name && calendar.isDateInToday(log.date)
        }
        return todayLogs.reduce(0) { $0 + $1.minutes }
    }
    
    private var totalMinutes: Int {
        let logsForItem = allLogs.filter { $0.itemName == item.name }
        return logsForItem.reduce(0) { $0 + $1.minutes }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .shadow(radius: 5)
                .frame(height: 150)
                .foregroundStyle(Color(.systemBackground))
            
            HStack {
                Button(action: {
                    onPlayStop(item)
                }) {
                    Image(systemName: isActive ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .padding()
                }
                
                VStack(alignment: .leading) {
                    // Skill name
                    Text(item.name)
                        .font(.headline)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                    
                    // Minutes today
                    let todayHours = todayMinutes / 60
                    let todayMinutes = todayMinutes % 60
                    Text("\(todayHours > 0 ? ("\(todayHours) h ") : "")\(todayMinutes) min today\(todayMinutes > 0 || todayHours > 0 ? "!" : "")")
                        .padding(.vertical, 3)
                    
                    // Total progress (in hours + minutes)
                    let totalLoggedMinutes = totalMinutes + item.startTime
                    let totalHours = totalLoggedMinutes / 60
                    let totalMins = totalLoggedMinutes % 60
                    Text("\(totalHours) h \(totalMins) min / 10000 h")
                    
                    // Progress bar
                    HStack {
                        ProgressView(value: Double(totalLoggedMinutes) / 60, total: 10000)
                            .padding(.trailing)
                        
                        let percent = Int(Double(totalLoggedMinutes) / 60 / 10000 * 100)
                        Text("\(percent)%")
                            .font(.caption)
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ItemView(
        item: Item(name: "Japanese", startTime: 200278, todayMinutes: 43),
        isActive: true, 
        onPlayStop: { _ in }
    )
}
