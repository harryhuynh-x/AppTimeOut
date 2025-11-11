import Foundation
import SwiftUI
import Combine
import StoreKit
import UIKit

public enum SubscriptionTier: String, CustomStringConvertible {
    case free
    case premiumMonthly
    case premiumYearly
    
    public var description: String {
        switch self {
        case .free:
            return "Free"
        case .premiumMonthly:
            return "Premium — Monthly"
        case .premiumYearly:
            return "Premium — Yearly"
        }
    }
}

@MainActor
public final class SubscriptionManager: ObservableObject {
    public static let shared = SubscriptionManager()
    
    #if DEBUG
    // Toggle this to true to simulate Premium during development
    public var debugForcePremium: Bool = true
    #endif
    
    @Published public private(set) var tier: SubscriptionTier = .free
    @Published public private(set) var expirationDate: Date? = nil
    @Published public private(set) var products: [Product] = []
    
    private let monthlyID = "com.example.app.premium.monthly"
    private let yearlyID = "com.example.app.premium.yearly"
    
    private init() {}
    
    public func loadProducts() async {
        let ids = Set([monthlyID, yearlyID])
        do {
            let fetched = try await Product.products(for: ids)
            self.products = fetched
        } catch {
            self.products = []
        }
    }
    
    public func refreshEntitlements() async {
        #if DEBUG
        if debugForcePremium {
            // Simulate a premium entitlement locally for testing
            self.tier = .premiumMonthly
            self.expirationDate = Calendar.current.date(byAdding: .month, value: 1, to: .now)
            return
        }
        #endif
        
        do {
            var best: StoreKit.Transaction? = nil
            for await ent in StoreKit.Transaction.currentEntitlements {
                if case .verified(let t) = ent {
                    if t.productID == monthlyID || t.productID == yearlyID {
                        if best == nil || (best!.purchaseDate < t.purchaseDate) {
                            best = t
                        }
                    }
                }
            }
            if let t = best {
                updateTier(from: t)
            } else {
                self.tier = .free
                self.expirationDate = nil
            }
        }
    }
    
    public func purchaseMonthly() async throws {
        try await purchase(productID: monthlyID)
    }
    
    public func purchaseYearly() async throws {
        try await purchase(productID: yearlyID)
    }
    
    private func purchase(productID: String) async throws {
        guard let product = products.first(where: { $0.id == productID }) else { return }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                updateTier(from: transaction)
            }
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
        await refreshEntitlements()
    }
    
    @MainActor
    public func manageSubscriptions() async {
        do {
            if let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }) {
                try await AppStore.showManageSubscriptions(in: scene)
            } else if let anyScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                try await AppStore.showManageSubscriptions(in: anyScene)
            } else {
                // No available UIWindowScene to present manage subscriptions.
                // Consider presenting an alert to the user.
            }
        } catch {
            // Handle error if needed
        }
    }
    
    @MainActor
    public func restore() async {
        await refreshEntitlements()
    }
    
    private func updateTier(from transaction: StoreKit.Transaction) {
        if transaction.productID == monthlyID {
            self.tier = .premiumMonthly
        } else if transaction.productID == yearlyID {
            self.tier = .premiumYearly
        } else {
            self.tier = .free
        }
        self.expirationDate = transaction.expirationDate
    }
}

#Preview {
    Text(SubscriptionManager.shared.tier.description)
}
