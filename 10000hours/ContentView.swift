//
//  ContentView.swift
//  10000hours
//
//  Created by Nathan Davis on 8/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    private let activeItemKey = "activeItemID"
    private let timerStartDateKey = "timerStartDate"
    private let elapsedSecondsKey = "elapsedSeconds"
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.order) private var items: [Item]
    @Query(sort: \LoggedItem.date, order: .reverse) private var logs: [LoggedItem]
    @State private var showNewItem = false
    @State private var itemToDelete: Item?
    @State private var activeItem: Item? = nil
    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer? = nil
    @State private var timerStartDate: Date? = nil
    
    @State private var showAddTimeOverlay = false
    @State private var addTimeHours = 0
    @State private var addTimeMinutes = 0
    @State private var comment = ""
    @State private var overlayItem: Item? = nil

    @State private var tick = false

    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .foregroundStyle(Color(.systemBackground))
                    .ignoresSafeArea()
                // add item button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showNewItem = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                        }
                    }
                    Spacer()
                }
                .padding()
                VStack {
                    Text("10000 Hours")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                    Spacer()
                    ScrollView {
                        ForEach(items) { item in
                            ZStack {
                                ItemView(
                                    item: item,
                                    isActive: activeItem?.id == item.id,
                                    onPlayStop: { selectedItem in
                                        if activeItem == selectedItem {
                                            // Stop the timer
                                            timer?.invalidate()
                                            timer = nil
                                            // Stop the timer using start date-based logic
                                            if let start = timerStartDate {
                                                let elapsed = Int(Date().timeIntervalSince(start))
                                                elapsedSeconds = elapsed
                                            }
                                            timerStartDate = nil
                                            activeItem = nil

                                            // Convert elapsedSeconds into hours and minutes
                                            addTimeHours = elapsedSeconds / 3600
                                            addTimeMinutes = (elapsedSeconds % 3600) / 60

                                            elapsedSeconds = 0
                                            overlayItem = selectedItem
                                            showAddTimeOverlay = true
                                        } else {
                                            // Start the timer for the selected item
                                            timer?.invalidate()
                                            activeItem = selectedItem
                                            elapsedSeconds = 0
                                            timerStartDate = Date()
                                            saveTimerState()
                                            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                                elapsedSeconds += 1
                                            }
                                        }
                                        // Show the add time overlay for the selected item
                                        saveTimerState()
                                    }
                                )
                                HStack {
                                    Spacer()
                                    Button(role: .destructive) {
                                        itemToDelete = item
                                    } label: {
                                        Label("", systemImage: "ellipsis")
                                            .rotationEffect(.degrees(90))
                                    }
                                }
                                HStack(spacing: 0) {
                                    Rectangle()
                                        .foregroundStyle(.clear)
                                        .frame(width: 50)
                                    NavigationLink(destination: LogItemListView(item: item)) {
                                        ZStack {
                                            Color.clear
                                                .contentShape(Rectangle())
                                                .frame(width: 340, height: 150)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    Color.clear
                                }
                            }
                        }
                        .onMove(perform: moveItems)
                        .onDelete(perform: deleteItems)
                    }
                    if let _ = activeItem {
                        Text(timerString())
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding()
                            .id(tick) // forces it to update with tick down below
                    }
                }
                if showAddTimeOverlay, let currentItem = overlayItem {
                    AddTimeView(
                        item: currentItem,
                        comment: $comment,
                        hours: $addTimeHours,
                        minutes: $addTimeMinutes,
                        showAddTimeOverlay: $showAddTimeOverlay,
                        overlayItem: $overlayItem
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .zIndex(1)
                }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                guard !showAddTimeOverlay else { return } // Prevent re-rendering while picker is up
                tick.toggle()
                if tick {
                    saveTimerState()
                }
            }
            .onAppear {
                if let savedID = UserDefaults.standard.string(forKey: activeItemKey),
                   let savedItem = items.first(where: { $0.id.uuidString == savedID }) {
                    activeItem = savedItem
                }
                
                if let startTimestamp = UserDefaults.standard.value(forKey: timerStartDateKey) as? TimeInterval {
                    timerStartDate = Date(timeIntervalSince1970: startTimestamp)
                }
                
                elapsedSeconds = UserDefaults.standard.integer(forKey: elapsedSecondsKey)
            }
        }
        .sheet(isPresented: $showNewItem) {
            NewItemView()
        }
        .alert("Delete Item?", isPresented: Binding<Bool>(
            get: { itemToDelete != nil },
            set: { if !$0 { itemToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let item = itemToDelete {
                    withAnimation {
                        let itemName = item.name
                        let logsToDelete = logs.filter { $0.itemName == itemName }
                        for log in logsToDelete {
                            modelContext.delete(log)
                        }
                        modelContext.delete(item)
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to delete item and its logs from alert: \(error)")
                        }
                    }
                    itemToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                itemToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this item?")
        }
    }
    
    private func saveTimerState() {
        if let activeItem = activeItem {
            UserDefaults.standard.set(activeItem.id.uuidString, forKey: activeItemKey)
        } else {
            UserDefaults.standard.removeObject(forKey: activeItemKey)
        }
        
        if let startDate = timerStartDate {
            UserDefaults.standard.set(startDate.timeIntervalSince1970, forKey: timerStartDateKey)
        } else {
            UserDefaults.standard.removeObject(forKey: timerStartDateKey)
        }
        
        UserDefaults.standard.set(elapsedSeconds, forKey: elapsedSecondsKey)
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(name: "New Item", startTime: 0, todayMinutes: 0, order: items.count)
            modelContext.insert(newItem)
            try? modelContext.save()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let item = items[index]
                // Delete all logs associated with this item
                let itemName = item.name
                let logsToDelete = logs.filter { $0.itemName == itemName }
                for log in logsToDelete {
                    modelContext.delete(log)
                }
                // Delete the item itself
                modelContext.delete(item)
            }

            do {
                try modelContext.save()
            } catch {
                print("Failed to delete item and its logs: \(error)")
            }
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        var reorderedItems = items
        reorderedItems.move(fromOffsets: source, toOffset: destination)
        
        for (index, item) in reorderedItems.enumerated() {
            item.order = index
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save item order: \(error)")
        }
    }
    
    private func timerString() -> String {
        var elapsed = elapsedSeconds
        if let start = timerStartDate {
            elapsed = Int(Date().timeIntervalSince(start))
        }
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        let seconds = elapsed % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, LoggedItem.self])
}
