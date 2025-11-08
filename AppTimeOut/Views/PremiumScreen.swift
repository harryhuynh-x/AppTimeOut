import SwiftUI

struct PremiumScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PremiumView()
            }
            .padding()
        }
        .navigationTitle("Go Premium")
    }
}

#Preview {
    NavigationStack {
        PremiumScreen()
    }
}
