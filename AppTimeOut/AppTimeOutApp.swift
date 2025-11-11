import Combine
import SwiftUI

@main
struct AppTimeOutApp: App {
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
