//
//  NewItemView.swift
//  10000hours
//
//  Created by Nathan Davis on 8/30/25.
//

import SwiftUI
import SwiftData

struct NewItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var itemName = ""
    @State private var startTime: Int? = nil

    var body: some View {
        NavigationStack {
            VStack {
//                Text("Create New Item")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .padding()

                TextField("Enter item name", text: $itemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.words)
                
                TextField("Enter starting hours", value: $startTime, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .keyboardType(.numberPad)
                    .onChange(of: startTime) { oldValue, newValue in
                        if let newValue = newValue, newValue < 0 {
                            startTime = 0
                        }
                    }

                Button(action: saveItem) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(itemName.isEmpty ? Color.gray : Color.blue)
                        .foregroundStyle(Color(.systemBackground))
                        .cornerRadius(10)
                }
                .padding()
                .disabled(itemName.isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("Create New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        startTime = nil
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveItem() {
        guard !itemName.isEmpty else { return }
        
        let newItem = Item(name: itemName, startTime: (startTime ?? 0) * 60) // convert to minutes
        modelContext.insert(newItem)
        do {
            try modelContext.save()  // 💾 Ensure it saves
            print("✅ modelContext Saved!")
        } catch {
            print("❌ Error saving: \(error.localizedDescription)")
        }
        startTime = nil
        dismiss()  // Close the view after saving
    }
}
