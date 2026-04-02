import Foundation
import RevenueCat

// MARK: - PurchaseManager
// Handles all RevenueCat subscription logic.
// Entitlements map to features unlocked in the Next.js web layer via Capacitor.

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var customerInfo: CustomerInfo?
    @Published var isProUser: Bool = false
    @Published var isEliteUser: Bool = false
    @Published var offerings: Offerings?

    // MARK: - Setup (call once in AppDelegate / App init)
    func configure() {
        Purchases.configure(withAPIKey: Config.revenueCatAPIKey)
        Purchases.shared.delegate = self

        Task { await refreshCustomerInfo() }
    }

    // MARK: - Fetch Offerings
    func fetchOfferings() async {
        do {
            offerings = try await Purchases.shared.offerings()
        } catch {
            print("[RevenueCat] Failed to fetch offerings: \(error)")
        }
    }

    // MARK: - Purchase a Package
    func purchase(package: Package) async throws -> CustomerInfo {
        let result = try await Purchases.shared.purchase(package: package)
        await handleCustomerInfo(result.customerInfo)
        return result.customerInfo
    }

    // MARK: - Restore Purchases
    func restorePurchases() async throws {
        let info = try await Purchases.shared.restorePurchases()
        await handleCustomerInfo(info)
    }

    // MARK: - Refresh Customer Info
    func refreshCustomerInfo() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            await handleCustomerInfo(info)
        } catch {
            print("[RevenueCat] Failed to refresh customer info: \(error)")
        }
    }

    // MARK: - Handle Entitlements
    private func handleCustomerInfo(_ info: CustomerInfo) async {
        customerInfo = info

        // Check entitlements (set these up in RevenueCat dashboard)
        isProUser   = info.entitlements["pro"]?.isActive == true
        isEliteUser = info.entitlements["elite"]?.isActive == true

        // Sync entitlement to web layer via Capacitor JS bridge
        syncEntitlementsToWebLayer()

        print("[RevenueCat] Pro: \(isProUser) | Elite: \(isEliteUser)")
    }

    // Push entitlement status into the Next.js app
    private func syncEntitlementsToWebLayer() {
        let tier = isEliteUser ? "elite" : isProUser ? "pro" : "free"
        let js = "window.dispatchEvent(new CustomEvent('entitlementUpdate', { detail: { tier: '\(tier)' } }))"
        NotificationCenter.default.post(
            name: NSNotification.Name("CAPBridgeJavaScriptExecute"),
            object: js
        )
    }
}

// MARK: - PurchasesDelegate (live updates)
extension PurchaseManager: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { await MainActor.run { Task { await self.handleCustomerInfo(customerInfo) } } }
    }
}

// MARK: - SwiftUI Paywall Helper
// Drop-in paywall view using RevenueCat's prebuilt UI
import RevenueCatUI

struct PaywallViewWrapper: View {
    @StateObject private var pm = PurchaseManager.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        PaywallView()
            .onPurchaseCompleted { info in
                print("[Paywall] Purchase completed: \(info)")
                dismiss()
            }
            .onRestoreCompleted { info in
                print("[Paywall] Restore completed: \(info)")
                dismiss()
            }
    }
}
