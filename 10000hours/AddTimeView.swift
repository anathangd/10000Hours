//
//  AddTimeView.swift
//  10000hours
//
//  Created by Nathan Davis on 8/30/25.
//

import SwiftUI
import SwiftData

struct AddTimeView: View {
    var item: Item
    @Binding var comment: String
    @Binding var hours: Int        // <-- receive elapsed hours
    @Binding var minutes: Int      // <-- receive elapsed minutes
    @State private var showingPicker = false
    @Binding var showAddTimeOverlay: Bool   // binding to dismiss overlay
    @Binding var overlayItem: Item?        // reference to current item
    @Environment(\.modelContext) private var modelContext
    @Query private var allLogs: [LoggedItem]
    public var frameWidth: CGFloat = 330
    
    private var popularDescriptions: [String] {
        var stats: [String: (count: Int, totalMinutes: Int, recentDate: Date)] = [:]
        for log in allLogs where log.itemName == item.name && !log.activityDescription.isEmpty {
            let entry = stats[log.activityDescription] ?? (0, 0, log.date)
            stats[log.activityDescription] = (
                entry.count + 1,
                entry.totalMinutes + log.minutes,
                max(entry.recentDate, log.date)
            )
        }
        return stats
            .sorted {
                if $0.value.totalMinutes == $1.value.totalMinutes {
                    return $0.value.recentDate > $1.value.recentDate
                }
                return $0.value.totalMinutes > $1.value.totalMinutes
            }
            .prefix(8) // cap at 8 most used
            .map { $0.key }
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color(.systemBackground))
                .ignoresSafeArea()
                .opacity(0.65)
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color(.systemBackground))
                .shadow(
                    color: Color.primary.opacity(0.15),
                    radius: 20,
                    x: 0,
                    y: 0
                )
                .shadow(
                    color: Color.primary.opacity(0.08),
                    radius: 6,
                    x: 0,
                    y: 0
                )
                .frame(width: frameWidth, height: showingPicker ? 475 : 335)
                .onTapGesture {
                    showingPicker = false
                }
            VStack {
                Text("Add Time")
                    .font(.title2)
                    .padding(10)
                VStack(alignment: .leading) {
                    if !showingPicker
                    {
                        HStack {
                            Image(systemName: "plus")
                                .padding(.leading, 9)
                            Button(action: {
                                withAnimation {
                                    showingPicker.toggle()
                                }
                            }) {
                                Text("\(hours > 0 ? "\(hours) h " : "")\(minutes) min")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    if showingPicker {
                        HStack {
                            Picker("Hours", selection: $hours) {
                                ForEach(0..<24) { h in
                                    Text("\(h) h").tag(h)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 100, height: 150)
                            .clipped()

                            Picker("Minutes", selection: $minutes) {
                                ForEach(0..<60) { m in
                                    Text("\(m) min").tag(m)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 100, height: 120)
                            .clipped()
                        }
                        .frame(maxWidth: frameWidth, alignment: .center)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    TextField("Description", text: $comment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: frameWidth - 30)
                        .padding(10)

                    // Show most used descriptions as buttons
                    VStack(alignment: .leading) {
                        let columns = 4
                        ForEach(Array(popularDescriptions.enumerated()), id: \.offset) { index, description in
                            if index % columns == 0 {
                                HStack {
                                    ForEach(popularDescriptions[index ..< min(index + columns, popularDescriptions.count)], id: \.self) { desc in
                                        Button(action: {
                                            comment = desc
                                        }) {
                                            Text(desc)
                                                .font(.subheadline)
                                                .padding(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.gray, lineWidth: 2)
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: frameWidth - 30, height: 50)
                    .padding()
                }
                .padding()
                
                // save and discard buttons
                HStack {
                    Button("Discard", role: .destructive) {
                        showAddTimeOverlay = false
                        overlayItem = nil
                    }
                    
                    .padding(10)
                    Button("Save") {
                        let totalMinutes = (hours * 60) + minutes
                        let newLog = LoggedItem(
                            itemName: item.name,
                            minutes: totalMinutes,
                            activityDescription: comment
                        )
                        modelContext.insert(newLog)
                        do {
                            try modelContext.save()
                            print("✅ Saved LoggedItem!")
                            print("total minutes: \(totalMinutes)")
                        } catch {
                            print("❌ Error saving LoggedItem: \(error)")
                        }

                        // Reset and close
                        showAddTimeOverlay = false
                        overlayItem = nil
                        comment = ""
                    }
                    .padding(10)
                }
            }
        }
    }
}

//#Preview {
//    AddTimeView(item: Item(name: "Japanese"), comment: .constant(""))
//}

    // Computed property for most used descriptions for this item
    
