//
//  LogItem.swift
//  10000hours
//
//  Created by Nathan Davis on 8/30/25.
//

import SwiftUI

struct LogItemView: View {
    var loggedItem: LoggedItem
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color(.systemBackground))
                .shadow(radius: 5)
                .frame(height: 100)
            HStack {
                VStack(alignment: .leading, spacing: 5){
                    Text(AppLocalization.logAdded(minutes: loggedItem.minutes))
                    Text(loggedItem.itemName)
                    Text(loggedItem.date.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    LogItemView(loggedItem: LoggedItem(itemName: "Japanese", minutes: 9, activityDescription: "Cards"))
}
