//
//  LogItemListView.swift
//  10000hours
//
//  Created by Nathan Davis on 8/31/25.
//

import SwiftUI
import SwiftData

struct LogItemListView: View {
    private let maxDescriptionLength = 100
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
    @State private var showSummarySheet = false

    var groupedMinutesByDescription: [(description: String, minutes: Int)] {
        Dictionary(grouping: filteredLogs) { log in
            let trimmed = log.activityDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? String(localized: "summary.other") : trimmed
        }
        .map { (description: $0.key, minutes: $0.value.reduce(0) { $0 + $1.minutes }) }
        .sorted {
            if $0.minutes == $1.minutes {
                return $0.description.localizedCaseInsensitiveCompare($1.description) == .orderedAscending
            }
            return $0.minutes > $1.minutes
        }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            List {
                ForEach(filteredLogs) { log in
                    HStack {
                        VStack(alignment: .leading, spacing: 5){
                            Text(AppLocalization.logAdded(minutes: log.minutes))
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
                            Label("common.delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            logToEdit = log
                            editedMinutes = log.minutes
                            editedDescription = log.activityDescription.limited(to: maxDescriptionLength)
                            showEditSheet = true
                        } label: {
                            Label("common.edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .listStyle(.plain)

            Button {
                showSummarySheet = true
            } label: {
                Image(systemName: "chart.bar.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(.blue))
                    .shadow(radius: 6)
            }
            .padding(.top, 10)
            .padding(.trailing, 16)
            .accessibilityLabel("log_list.summary.accessibility_label")
        }
        .navigationTitle(AppLocalization.logListTitle(itemName: item.name, count: filteredLogs.count))
        .onAppear() {
            print("count of logged items: \(allLogs.count)")
        }
        .alert("log_list.delete.title", isPresented: $showDeleteConfirmation) {
            if let log = logToDelete {
                Button("common.delete", role: .destructive) {
                    modelContext.delete(log)
                    try? modelContext.save()
                }
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text(AppLocalization.logDeleteMessage(minutes: logToDelete?.minutes ?? 0))
        }
        .sheet(isPresented: $showEditSheet) {
            VStack {
                Text("log_list.edit.title")
                    .font(.headline)
                    .padding(30)
                
                VStack {
                    Text("common.minutes_label")
                    TextField("common.minutes_placeholder", value: $editedMinutes, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.vertical)

                VStack {
                    Text("common.description_label")
                    TextField("common.description_placeholder", text: $editedDescription.limited(to: maxDescriptionLength))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.vertical)

                HStack {
                    Button("common.cancel", role: .cancel) {
                        showEditSheet = false
                    }
                    Spacer()
                    Button("common.save") {
                        if let log = logToEdit {
                            editedDescription = editedDescription.limited(to: maxDescriptionLength)
                            log.minutes = editedMinutes
                            log.activityDescription = editedDescription.limited(to: maxDescriptionLength)
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
        .sheet(isPresented: $showSummarySheet) {
            ActivityHoursSummarySheet(summaryRows: groupedMinutesByDescription)
        }
    }
}

struct ActivityHoursSummarySheet: View {
    var summaryRows: [(description: String, minutes: Int)]

    private var totalMinutes: Int {
        summaryRows.reduce(0) { $0 + $1.minutes }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    if summaryRows.isEmpty {
                        Text("summary.empty")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(summaryRows, id: \.description) { row in
                            HStack {
                                Text(row.description)
                                Spacer()
                                Text(hoursString(from: row.minutes))
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }

                Divider()

                HStack {
                    Text("common.total")
                        .fontWeight(.bold)
                    Spacer()
                    Text(hoursString(from: totalMinutes))
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color(.systemBackground))
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func hoursString(from minutes: Int) -> String {
        AppLocalization.summaryHours(minutes: minutes)
    }
}

#Preview {
    LogItemListView(item: Item(name: "Japanese"))
}
