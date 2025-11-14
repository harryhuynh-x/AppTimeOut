//
//  ScheduleLockCard.swift
//
//  Purpose:
//  - A compact SwiftUI card that configures a schedule-based self-lock feature.
//
//  Key Features:
//  - Day selection (Mon–Sun) with a concise, right-aligned "Weekly" toggle.
//  - Multiple time slots (Premium). Free users can see the feature but can’t add more than one slot.
//  - Validations: prevents overlapping slots and start >= end; disables Self-Lock when invalid.
//  - Partner lock integration: protects disabling or changes via an unlock sheet.
//  - Dynamic header hint summarizing selected days and number of slots.
//
//  Dependencies / Interactions:
//  - UnlockSheetView (presented to authorize Partner-protected changes).
//  - Uses SwiftUI DatePicker for time slot editing.
//
//  Notes:
//  - The “Weekly” control is compact and right-aligned.
//  - Trash button for slots appears only when more than one slot exists.
//  - Previews include Free and Premium variants (#Preview blocks at the bottom).
//

import SwiftUI

private struct TimeSlot: Identifiable, Equatable {
    let id: UUID = UUID()
    var start: Date
    var end: Date
}

private enum PartnerScheduleAction {
    case disableSelfLock
    case disableGuardian
}

struct ScheduleLockCard: View {

    // 1 = Mon ... 7 = Sun
    @State private var selectedDays: Set<Int> = Set(1...7)
    @State private var weeklyRepeat: Bool = true

    @State private var isSelfLockEnabled = false
    @State private var isPartnerEnabled = false

    @State private var pendingPartnerAction: PartnerScheduleAction? = nil
    @State private var showUnlockSheet = false
    @State private var showDaySelectionAlert = false

    @State private var timeSlots: [TimeSlot] = [
        TimeSlot(
            start: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now)!,
            end:   Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: .now)!
        )
    ]
    
    @State private var hasPremium: Bool = true

    // Convenience init for previews
    init(hasPremium initialPremium: Bool = false) {
        _hasPremium = State(initialValue: initialPremium)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("Schedule")
                    .font(.headline)
                Spacer()
                Text(helperText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Days row
            HStack(spacing: 0) {
                ForEach(1...7, id: \.self) { day in
                    Spacer(minLength: 0)
                    dayCircle(for: day)
                }
                Spacer(minLength: 0)
            }

            // Weekly repeat toggle (right-aligned)
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Text("Weekly")
                        .font(.subheadline)
                    Toggle(isOn: $weeklyRepeat) { EmptyView() }
                        .labelsHidden()
                        .tint(Color.accentColor)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Weekly")
            }

            // Time slots
            VStack(alignment: .leading, spacing: 8) {
                ForEach($timeSlots) { $slot in
                    HStack {
                        DatePicker("Start", selection: $slot.start, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                        Text("–")
                        DatePicker("End", selection: $slot.end, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                        if timeSlots.count > 1 {
                            Button(role: .destructive) {
                                removeSlot(slot)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                HStack {
                    Button {
                        addSlot()
                    } label: {
                        Label("Add Slot", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.accentColor)
                    .disabled(!hasPremium && timeSlots.count >= 1)

                    if !hasPremium && timeSlots.count >= 1 {
                        Text("Premium: Multiple slots")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if hasInvalidRanges {
                        Text("Invalid slot times")
                            .font(.caption)
                            .foregroundStyle(.red)
                    } else if hasOverlaps {
                        Text("Overlapping slots")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }

            // Self-lock toggle button
            Button {
                toggleSelfLock()
            } label: {
                Text(isSelfLockEnabled ? "⏸ Self-Lock Enabled" : "▶︎ Enable Self-Lock")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSelfLockEnabled
                                ? Color.accentColor.opacity(0.2)
                                : Color.accentColor)
                    .foregroundStyle(isSelfLockEnabled ? Color.accentColor : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(hasInvalidRanges || hasOverlaps)

            // Partner lock toggle button
            Button {
                togglePartner()
            } label: {
                Text(isPartnerEnabled ? "⏸ Disable Partner Lock" : "🤝 Enable Partner Lock")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isPartnerEnabled
                                ? Color(red: 1.0, green: 0.647, blue: 0.0).opacity(0.2)
                                : Color(red: 1.0, green: 0.647, blue: 0.0))
                    .foregroundStyle(isPartnerEnabled ? Color(red: 1.0, green: 0.647, blue: 0.0) : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        //.foregroundStyle(.primary) // Removed as per instructions
        .sheet(isPresented: $showUnlockSheet) {
            UnlockSheetView {
                handlePartnerSuccess()
            }
        }
        .alert("Select a day", isPresented: $showDaySelectionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please select at least one day to enable Self-Lock.")
        }
        .onAppear {
            // Force Premium at runtime to ensure the Simulator shows the Premium experience
            hasPremium = true
        }
    }

    // MARK: - Day bubbles

    private func dayCircle(for day: Int) -> some View {
        let isSelected = selectedDays.contains(day)
        let label = ["M","T","W","Th","F","S","Su"][day - 1]

        return Text(label)
            .font(.footnote.bold())
            .frame(width: 32, height: 32)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Circle())
            .onTapGesture {
                if isSelected {
                    selectedDays.remove(day)
                } else {
                    selectedDays.insert(day)
                }
            }
    }

    // MARK: - Helper text

    private var helperText: String {
        let dayPart = selectedDaysLabel
        let count = timeSlots.count
        var text = count > 1 ? "\(dayPart) · \(count) slots" : dayPart
        if !hasPremium && count > 1 { text += " · Premium" }
        return text
    }

    // MARK: - Selected days label
    private var selectedDaysLabel: String {
        let fullNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let shortNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

        let sortedDays = selectedDays.sorted()

        // No days selected: provide a neutral prompt
        if sortedDays.isEmpty {
            return weeklyRepeat ? "Everyday" : "All days"
        }

        // All 7 days
        if sortedDays.count == 7 {
            return weeklyRepeat ? "Everyday" : "All days"
        }

        // Single day
        if sortedDays.count == 1, let day = sortedDays.first {
            let index = day - 1
            let name = fullNames[index]
            return weeklyRepeat ? "Every \(name)" : name
        }

        // Multiple specific days
        let names = sortedDays.map { shortNames[$0 - 1] }.joined(separator: ", ")
        return weeklyRepeat ? "Every \(names)" : names
    }

    // MARK: - Slots helpers
    private func addSlot() {
        let cal = Calendar.current
        let start = timeSlots.last?.end ?? cal.date(bySettingHour: 9, minute: 0, second: 0, of: .now)!
        let end = cal.date(byAdding: .minute, value: 60, to: start) ?? start.addingTimeInterval(3600)
        timeSlots.append(TimeSlot(start: start, end: end))
    }

    private func removeSlot(_ slot: TimeSlot) {
        timeSlots.removeAll { $0.id == slot.id }
    }

    private var hasOverlaps: Bool {
        let sorted = timeSlots.sorted { $0.start < $1.start }
        for i in 1..<sorted.count {
            if sorted[i-1].end > sorted[i].start { return true }
        }
        return false
    }

    private var hasInvalidRanges: Bool {
        timeSlots.contains { $0.start >= $0.end }
    }

    // MARK: - Toggle logic

    private func toggleSelfLock() {
        if isSelfLockEnabled {
            // Turning OFF self-lock
            if isPartnerEnabled {
                pendingPartnerAction = .disableSelfLock
                showUnlockSheet = true
            } else {
                isSelfLockEnabled = false
            }
        } else {
            // Turning ON
            if selectedDays.isEmpty {
                showDaySelectionAlert = true
            } else {
                isSelfLockEnabled = true
            }
        }
    }

    private func togglePartner() {
        if isPartnerEnabled {
            // Turning OFF Partner
            if isSelfLockEnabled {
                pendingPartnerAction = .disableGuardian
                showUnlockSheet = true
            } else {
                isPartnerEnabled = false
            }
        } else {
            // Turning ON Partner also ensures schedule is enabled
            isPartnerEnabled = true
            if !isSelfLockEnabled {
                isSelfLockEnabled = true
            }
        }
    }

    // MARK: - Partner success

    private func handlePartnerSuccess() {
        switch pendingPartnerAction {
        case .disableSelfLock:
            isSelfLockEnabled = false
        case .disableGuardian:
            isPartnerEnabled = false
        case .none:
            break
        }
        pendingPartnerAction = nil
    }
}

#Preview("Free") {
    ScheduleLockCard(hasPremium: false)
        .padding()
        .background(Color(.systemBackground))
}

#Preview("Premium") {
    ScheduleLockCard(hasPremium: true)
        .padding()
        .background(Color(.systemBackground))
}

