import SwiftUI

struct LockDashboardView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("AppTimeOut")
                    .font(.largeTitle.bold())

                Text("Lock Dashboard placeholder.\nYou’ll put your timer and lock controls here.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("Lock")
        }
    }
}

#Preview {
    LockDashboardView()
}

