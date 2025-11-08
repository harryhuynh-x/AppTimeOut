import SwiftUI

private enum GuardianScheduleAction {
    case disableSelfLock
    case disableGuardian
}

struct ScheduleLockCard: View {

    // 1 = Mon ... 7 = Sun
    @State private var selectedDays: Set<Int> = [1]
    @State private var startTime: Date = Calendar.current.date(
        bySettingHour: 8, minute: 0, second: 0, of: .now)!
    @State private var endTime: Date = Calendar.current.date(
        bySettingHour: 17, minute: 0, second: 0, of: .now)!

    @State private var isSelfLockEnabled = false
    @State private var isGuardianEnabled = false

    @State private var pendingGuardianAction: GuardianScheduleAction? = nil
    @State private var showUnlockSheet = false
    @State private var showDaySelectionAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Schedule")
                .font(.headline)

            // Days row
            HStack(spacing: 0) {
                ForEach(1...7, id: \.self) { day in
                    Spacer(minLength: 0)
                    dayCircle(for: day)
                }
                Spacer(minLength: 0)
            }

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

            Text(helperText)
                .font(.caption)
                .foregroundStyle(.secondary)
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
        if isGuardianEnabled {
            return "Guardian lock: disabling or changing this schedule can be protected by a code."
        } else if isSelfLockEnabled {
            return "Self-lock schedule active for selected days."
        } else {
            return "Pick days and times, then enable Self-Lock. Premium later: per-day custom schedules."
        }
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

