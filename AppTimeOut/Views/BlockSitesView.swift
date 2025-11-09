import SwiftUI

struct BlockSitesView: View {
    @State private var subscription: SubscriptionLevel = .free

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Reuse the existing blocked apps/sites management UI
                BlockingView(subscription: subscription)
            }
            .padding()
        }
        .navigationTitle("Blocking")
    }
}

#Preview {
    NavigationStack {
        BlockSitesView()
    }
}
