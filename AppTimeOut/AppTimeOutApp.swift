import Combine
import SwiftUI
import FirebaseCore

@main
struct AppTimeOutApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some Scene {
        WindowGroup {
            LockDashboardView()
                .onOpenURL { url in
                    let _ = GoogleSignInManager.shared.handle(url: url)
                    let _ = FacebookLoginManager.shared.application(open: url)
                }
                .tint(.accentColor)
                .environmentObject(subscriptionManager)
                .task {
                    await subscriptionManager.refreshEntitlements()
                    await subscriptionManager.loadProducts()
                }
        }
    }
}
