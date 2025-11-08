import SwiftUI

struct PartnerSettingsScreen: View {
    @State private var subscription: SubscriptionLevel = .free

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Reuse the existing partner settings UI
                PartnerSettingsView(subscription: subscription)
            }
            .padding()
        }
        .navigationTitle("Partner & Settings")
    }
}

#Preview {
    NavigationStack {
        PartnerSettingsScreen()
    }
}
