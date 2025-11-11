import SwiftUI

struct PartnerSettingsView: View {
    let subscription: SubscriptionLevel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Partner & Settings")
                    .font(.title2.bold())

                Text("Here you’ll manage your accountability partner and app preferences.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text(subscription == .free
                     ? "Free: 1 partner."
                     : "Profile: multiple partners.")
                    .font(.subheadline)

                Spacer()
            }
            .padding()
            .navigationTitle("Partner & Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

