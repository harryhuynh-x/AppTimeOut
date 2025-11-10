import StoreKit
import SwiftUI

public enum SubscriptionTier {
    case free
    case premiumMonthly
    case premiumYearly
}

@MainActor
public final class SubscriptionManager: ObservableObject {
    public static let shared = SubscriptionManager()
    
    @Published public private(set) var tier: SubscriptionTier = .free
    @Published public private(set) var expirationDate: Date? = nil
    @Published public private(set) var products: [Product] = []
    
    let monthlyID = "com.example.app.premium.monthly"
    let yearlyID = "com.example.app.premium.yearly"
    
    public func loadProducts() async {
        do {
            let products = try await Product.products(for: [monthlyID, yearlyID])
            self.products = products
        } catch {
            self.products = []
        }
    }
    
    public func refreshEntitlements() async {
        var foundTransaction: Transaction? = nil
        for await verificationResult in Transaction.currentEntitlements {
            switch verificationResult {
            case .verified(let transaction):
                if transaction.productID == monthlyID || transaction.productID == yearlyID {
                    if let current = foundTransaction {
                        if let currentExpiration = current.expirationDate,
                           let newExpiration = transaction.expirationDate,
                           newExpiration > currentExpiration {
                            foundTransaction = transaction
                        }
                    } else {
                        foundTransaction = transaction
                    }
                }
            case .unverified:
                continue
            }
        }
        
        if let transaction = foundTransaction {
            updateTier(from: transaction)
        } else {
            tier = .free
            expirationDate = nil
        }
    }
    
    public func purchaseMonthly() async throws {
        guard let product = products.first(where: { $0.id == monthlyID }) else { return }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try verification.payloadValue()
            await refreshEntitlements()
            await transaction.finish()
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }
    
    public func purchaseYearly() async throws {
        guard let product = products.first(where: { $0.id == yearlyID }) else { return }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try verification.payloadValue()
            await refreshEntitlements()
            await transaction.finish()
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }
    
    public func manageSubscriptions() async {
        await AppStore.showManageSubscriptions(in: nil)
    }
    
    public func restore() async {
        _ = try? await Transaction.latest(for: monthlyID)
        _ = try? await Transaction.latest(for: yearlyID)
        await refreshEntitlements()
    }
    
    private func updateTier(from transaction: Transaction) {
        guard let subscriptionInfo = transaction.subscriptionInfo else {
            tier = .free
            expirationDate = nil
            return
        }
        let currentProductID = subscriptionInfo.renewalInfo.currentProductID
        if currentProductID == monthlyID {
            tier = .premiumMonthly
        } else if currentProductID == yearlyID {
            tier = .premiumYearly
        } else {
            tier = .free
        }
        expirationDate = transaction.expirationDate
    }
}

#Preview {
    Text("Subscription Tier: \(SubscriptionManager.shared.tier)")
}
