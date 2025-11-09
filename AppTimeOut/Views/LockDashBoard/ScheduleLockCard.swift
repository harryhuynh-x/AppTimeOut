import SwiftUI

private enum GuardianScheduleAction {
    case disableSelfLock
    case disableGuardian
}

struct ScheduleLockCard: View {

    // 1 = Mon ... 7 = Sun
    @State private var selectedDays: Set<Int> = Set(1...7)
    @State private var startTime: Date = Calendar.current.date(
        bySettingHour: 8, minute: 0, second: 0, of: .now)!
    @State private var endTime: Date = Calendar.current.date(
        bySettingHour: 17, minute: 0, second: 0, of: .now)!
    @State private var weeklyRepeat: Bool = true

    @State private var isSelfLockEnabled = false
    @State private var isGuardianEnabled = false

    @State private var pendingGuardianAction: GuardianScheduleAction? = nil
    @State private var showUnlockSheet = false
    @State private var showDaySelectionAlert = false

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

            // Weekly repeat toggle (native switch)
            Toggle(isOn: $weeklyRepeat) {
                Text("Weekly")
            }
            .tint(Color.accentColor)
            .font(.subheadline)

            // Time range
            HStack {
                DatePicker("Start", selection: $startTime,
                           displayedComponents: .hourAndMinute)
                    .labelsHidden()
                Spacer()
                Text("–")
                Spacer()
                DatePicker("End", selection: $endTime,
                           displayedComponents: .hourAndMinute)
                    .labelsHidden()
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

            // Guardian lock toggle button
            Button {
                toggleGuardian()
            } label: {
                Text(isGuardianEnabled ? "⏸ Disable Guardian Lock" : "🛡 Enable Guardian Lock")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isGuardianEnabled
                                ? Color.orange.opacity(0.2)
                                : Color.orange)
                    .foregroundStyle(isGuardianEnabled ? Color.orange : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .sheet(isPresented: $showUnlockSheet) {
            UnlockSheetView {
                handleGuardianSuccess()
            }
        }
        .alert("Select a day", isPresented: $showDaySelectionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please select at least one day to enable Self-Lock.")
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
        selectedDaysLabel
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

    // MARK: - Toggle logic

    private func toggleSelfLock() {
        if isSelfLockEnabled {
            // Turning OFF self-lock
            if isGuardianEnabled {
                pendingGuardianAction = .disableSelfLock
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

    private func toggleGuardian() {
        if isGuardianEnabled {
            // Turning OFF Guardian
            if isSelfLockEnabled {
                pendingGuardianAction = .disableGuardian
                showUnlockSheet = true
            } else {
                isGuardianEnabled = false
            }
        } else {
            // Turning ON Guardian also ensures schedule is enabled
            isGuardianEnabled = true
            if !isSelfLockEnabled {
                isSelfLockEnabled = true
            }
        }
    }

    // MARK: - Guardian success

    private func handleGuardianSuccess() {
        switch pendingGuardianAction {
        case .disableSelfLock:
            isSelfLockEnabled = false
        case .disableGuardian:
            isGuardianEnabled = false
        case .none:
            break
        }
        pendingGuardianAction = nil
    }
}
