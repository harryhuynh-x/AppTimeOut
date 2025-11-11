import SwiftUI

struct LockDashboardView: View {
    @EnvironmentObject var subs: SubscriptionManager

    private var currentLevel: SubscriptionLevel { subs.tier == .free ? .free : .premium }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Quick Timer Lock card
                    TimerLockCard()

                    // Scheduled Lock card
                    ScheduleLockCard()
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text("Dashboard")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("AppTimeOut")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        NavigationLink(destination: BlockingView(subscription: currentLevel)) {
                            Label("Manage Blocks", systemImage: "globe")
                        }
                        NavigationLink(destination: ProfileScreen()) {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

#Preview {
    LockDashboardView()
}
