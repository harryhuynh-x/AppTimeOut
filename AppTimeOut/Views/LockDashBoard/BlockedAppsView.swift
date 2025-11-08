import SwiftUI

struct BlockedAppsView: View {
    let subscription: SubscriptionLevel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Blocked Sites & Apps")
                    .font(.title2.bold())

                Text(subscription == .free
                     ? "Free: up to 4 items."
                     : "Premium: more items + extra controls.")
                    .font(.subheadline)

                // Later: list + add/remove UI

                Spacer()
            }
            .padding()
            .navigationTitle("Blocked Apps")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
