import SwiftUI

struct BlockSitesView: View {
    @State private var subscription: SubscriptionLevel = .free

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Reuse the existing blocked apps/sites management UI
                BlockedAppsView(subscription: subscription)
            }
            .padding()
        }
        .navigationTitle("Block Sites")
    }
}

#Preview {
    NavigationStack {
        BlockSitesView()
    }
}
