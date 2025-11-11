import SwiftUI
import StoreKit
import Combine

struct ProfileScreen: View {
    @EnvironmentObject var manager: SubscriptionManager
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
    
    var body: some View {
        List {
            Section("Account") {
                Button {
                    // TODO: Apple sign in action
                } label: {
                    HStack {
                        Image(systemName: "applelogo")
                        Text("Sign in with Apple")
                    }
                }
                Button {
                    Task { await GoogleSignInManager.shared.signIn() }
                } label: {
                    HStack {
                        Image(systemName: "g.circle")
                        Text("Sign in with Google")
                    }
                }
                Button {
                    Task { await FacebookLoginManager.shared.signIn() }
                } label: {
                    HStack {
                        Image(systemName: "f.circle")
                        Text("Sign in with Facebook")
                    }
                }
                Button {
                    // TODO: Email sign in action
                } label: {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Sign in with Email")
                    }
                }
            }
            
            Section("Subscription") {
                Text("Status: \(manager.tier.description)")
                if manager.tier != .free {
                    HStack {
                        Text("Plan")
                        Spacer()
                        Text(manager.tier.description)
                            .foregroundColor(.secondary)
                    }
                    if let expiration = manager.expirationDate {
                        HStack {
                            Text("Expires")
                            Spacer()
                            Text(dateFormatter.string(from: expiration))
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Button("$0.99 / month – Upgrade") {
                        Task {
                            try? await manager.purchaseMonthly()
                        }
                    }
                    Button("$10 / year – Upgrade") {
                        Task {
                            try? await manager.purchaseYearly()
                        }
                    }
                }
            }
            
            Section("Manage") {
                if manager.tier != .free {
                    Button("Cancel Premium", role: .destructive) {
                        Task {
                            await manager.manageSubscriptions()
                        }
                    }
                } else {
                    Button("Manage Subscription") {
                        Task {
                            await manager.manageSubscriptions()
                        }
                    }
                }
                Button("Restore Purchases") {
                    Task {
                        await manager.restore()
                    }
                }
            }
            
#if DEBUG
            Section("Debug") {
                Toggle(isOn: Binding<Bool>(
                    get: { manager.debugForcePremium },
                    set: { newValue in
                        manager.debugForcePremium = newValue
                        Task { await manager.refreshEntitlements() }
                    }
                )) {
                    Text("Force Premium (Debug)")
                }
            }
#endif
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await manager.loadProducts()
            await manager.refreshEntitlements()
        }
    }
}

#Preview {
    NavigationStack {
        ProfileScreen()
    }
}
