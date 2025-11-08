import SwiftUI
import Combine

private enum TimerState {
    case idle      // before start
    case running   // counting down
    case paused    // stopped mid-way
    case finished  // hit zero, waiting for reset
}

struct TimerLockCard: View {

    // MARK: - State

    @State private var state: TimerState = .idle
    @State private var totalSeconds: Int = 300
    @State private var remainingSeconds: Int = 300

    @State private var timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()

    // Keep for later when you enforce free vs premium
    private let freeMaxSeconds = 8 * 60 * 60

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timer")
                .font(.headline)

            content
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onReceive(timer) { _ in
            guard state == .running else { return }
            tick()
        }
    }

    // MARK: - View content

    @ViewBuilder
    private var content: some View {
        switch state {
        case .idle:
            idleView
        case .running:
            runningView
        case .paused, .finished:
            pausedView
        }
    }

    // Idle state UI
    private var idleView: some View {
        VStack(spacing: 10) {
            Text(timeString(from: totalSeconds))
                .font(.system(size: 40, weight: .bold, design: .rounded))

            addButtons

            Button {
                startTimer()
            } label: {
                Image(systemName: "play.fill")
                    .font(.system(size: 22, weight: .bold))
                    .frame(width: 72, height: 36)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 8)
                    .background(totalSeconds > 0 ? Color.accentColor : Color.gray.opacity(0.4))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .disabled(totalSeconds == 0)
        }
        .frame(maxWidth: .infinity)
    }

    // Running state UI
    private var runningView: some View {
        VStack(spacing: 16) {
            ZStack {
                let progress = totalSeconds > 0
                    ? Double(remainingSeconds) / Double(totalSeconds)
                    : 0

                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: CGFloat(max(min(progress, 1), 0)))
                    .stroke(Color.accentColor,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.2), value: progress)

                Text(timeString(from: remainingSeconds))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
            }
            .frame(width: 140, height: 140)

            Button {
                state = .paused
            } label: {
                Image(systemName: "pause.fill")
                    .font(.system(size: 22, weight: .bold))
                    .frame(width: 72, height: 36)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 8)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
    }

    // Paused/Finished state UI
    private var pausedView: some View {
        VStack(spacing: 10) {
            Text(timeString(from: remainingSeconds))
                .font(.system(size: 40, weight: .bold, design: .rounded))

            addButtons

            HStack(spacing: 24) {
                // Resume
                Button {
                    if remainingSeconds > 0 {
                        state = .running
                    }
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 60, height: 32)
                        .background(remainingSeconds > 0
                                    ? Color.accentColor
                                    : Color.gray.opacity(0.4))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .disabled(remainingSeconds == 0)

                // Reset
                Button {
                    resetTimer()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 60, height: 32)
                        .background(Color.gray.opacity(0.15))
                        .foregroundStyle(.primary)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // Add-time buttons, only active when not running
    private var addButtons: some View {
        HStack(spacing: 12) {
            addButton("+0:30", 30)
            addButton("+1:00", 60)
            addButton("+5:00", 5 * 60)
        }
        .opacity(state == .running ? 0.2 : 1)
        .allowsHitTesting(state != .running)
    }

    private func addButton(_ label: String, _ seconds: Int) -> some View {
        Button {
            totalSeconds += seconds
            remainingSeconds += seconds
            if state == .idle {
                remainingSeconds = totalSeconds
            }
        } label: {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.15))
                .clipShape(Capsule())
        }
    }

    // MARK: - Timer logic

    private func startTimer() {
        guard totalSeconds > 0 else { return }
        // NOTE: later you can clamp totalSeconds for free users using freeMaxSeconds
        remainingSeconds = totalSeconds
        state = .running
    }

    private func resetTimer() {
        state = .idle
        totalSeconds = 300
        remainingSeconds = 300
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            state = .finished
            return
        }
        remainingSeconds -= 1
    }

    private func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
