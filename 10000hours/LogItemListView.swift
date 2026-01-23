//
//  LogItemListView.swift
//  10000hours
//
//  Created by Nathan Davis on 8/31/25.
//

import SwiftUI
import SwiftData

struct LogItemListView: View {
    var item: Item
    @Environment(\.modelContext) private var modelContext
    @Query private var allLogs: [LoggedItem]

    var filteredLogs: [LoggedItem] {
        allLogs
            .filter { $0.itemName == item.name }
            .sorted { $0.date > $1.date }
    }

    @State private var showDeleteConfirmation = false
    @State private var logToDelete: LoggedItem? = nil
    @State private var logToEdit: LoggedItem? = nil
    @State private var editedMinutes: Int = 0
    @State private var editedDescription: String = ""
    @State private var showEditSheet = false
    
    var body: some View {
        List {
            ForEach(filteredLogs) { log in
                HStack {
                    VStack(alignment: .leading, spacing: 5){
                        Text("+ \(log.minutes / 60 > 0 ? "\(log.minutes / 60) h " : "")\(log.minutes % 60) minutes")
                        if log.activityDescription != "" {
                            Text(log.activityDescription)
                        }
                        Text(log.date.formatted(date: .long, time: .shortened))
                            .font(.subheadline)
                    }
                    Spacer()
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        logToDelete = log
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        logToEdit = log
                        editedMinutes = log.minutes
                        editedDescription = log.activityDescription
                        showEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("\(item.name) (\(filteredLogs.count) items)")
        .onAppear() {
            print("count of logged items: \(allLogs.count)")
        }
        .alert("Delete Log?", isPresented: $showDeleteConfirmation) {
            if let log = logToDelete {
                Button("Delete", role: .destructive) {
                    modelContext.delete(log)
                    try? modelContext.save()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this log entry of \(logToDelete?.minutes ?? 0) minutes?")
        }
        .sheet(isPresented: $showEditSheet) {
            VStack {
                Text("Edit Log")
                    .font(.headline)
                    .padding(30)
                
                VStack {
                    Text("Minutes:")
                    TextField("Minutes", value: $editedMinutes, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.vertical)

                VStack {
                    Text("Description:")
                    TextField("Description", text: $editedDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.vertical)

                HStack {
                    Button("Cancel", role: .cancel) {
                        showEditSheet = false
                    }
                    Spacer()
                    Button("Save") {
                        if let log = logToEdit {
                            log.minutes = editedMinutes
                            log.activityDescription = editedDescription
                            try? modelContext.save()
                        }
                        showEditSheet = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .padding()
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    LogItemListView(item: Item(name: "Japanese"))
}
