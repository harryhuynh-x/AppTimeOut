import SwiftUI

struct LockDashboardView: View {
    // Track current subscription state for the dashboard
    @State private var subscription: SubscriptionLevel = .free

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
                        NavigationLink(destination: LockDashboardView()) {
                            Label("Lock Dashboard", systemImage: "lock")
                        }
                        NavigationLink(destination: BlockSitesView()) {
                            Label("Block Sites", systemImage: "globe")
                        }
                        NavigationLink(destination: PartnerSettingsScreen()) {
                            Label("Partner & Settings", systemImage: "person.2")
                        }
                        NavigationLink(destination: PremiumScreen()) {
                            Label("Go Premium", systemImage: "star.circle")
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
