import SwiftUI

struct PremiumView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Go Premium")
                    .font(.title.bold())

                Text("""
                • Longer lock duration (>8 hr)
                • Custom schedules per day
                • More blocked apps/sites
                • Multiple partners/guardians
                """)
                .multilineTextAlignment(.leading)

                Button {
                    // TODO: integrate StoreKit 2
                } label: {
                    Text("$1 / month – Upgrade")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button("Restore Purchases") {
                    // TODO: restore
                }
                .padding(.top, 4)

                Spacer()
            }
            .padding()
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
