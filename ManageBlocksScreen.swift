import SwiftUI

struct ManageBlocksScreen: View {
    @StateObject private var model = ManageBlocksViewModel()
    @State private var showingAdd = false
    @State private var addType: BlockType = .domain
    @State private var addValue: String = ""
    @State private var addNotes: String = ""

    var body: some View {
        List {
            if model.isLoading {
                ProgressView("Loading blocks...")
            }
            if let msg = model.errorMessage {
                Text(msg).foregroundStyle(.red)
            }
            Section {
                ForEach(model.blocks) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.type.displayName)
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(Capsule())
                                Spacer()
                                Toggle("", isOn: Binding(get: {
                                    item.isActive
                                }, set: { newVal in
                                    Task { await model.toggle(item, active: newVal) }
                                }))
                                .labelsHidden()
                            }
                            Text(item.value).font(.body)
                            if let notes = item.notes, !notes.isEmpty {
                                Text(notes).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            Task { await model.remove(item) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            } header: {
                Text("Blocks")
            } footer: {
                Text("Swipe left to delete. Toggle to enable/disable a block.")
            }
        }
        .navigationTitle("Manage Blocks")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            await model.load()
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack {
                Form {
                    Picker("Type", selection: $addType) {
                        ForEach(BlockType.allCases) { t in
                            Text(t.displayName).tag(t)
                        }
                    }
                    TextField("Value (e.g., example.com or App Name)", text: $addValue)
                    TextField("Notes (optional)", text: $addNotes)
                }
                .navigationTitle("Add Block")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingAdd = false
                            addValue = ""
                            addNotes = ""
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            let value = addValue.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !value.isEmpty else { return }
                            Task {
                                await model.add(type: addType, value: value, notes: addNotes.isEmpty ? nil : addNotes)
                                showingAdd = false
                                addValue = ""
                                addNotes = ""
                            }
                        }
                        .disabled(addValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ManageBlocksScreen()
    }
}
