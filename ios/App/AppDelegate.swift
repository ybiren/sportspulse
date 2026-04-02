import UIKit
import UserNotifications
import Capacitor

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Register for remote push notifications
        registerForPushNotifications(application)
        return true
    }

    // MARK: - Push Notification Registration

    private func registerForPushNotifications(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else {
                print("[APNs] Permission denied: \(error?.localizedDescription ?? "unknown")")
                return
            }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }

    // MARK: APNs Token — send to Supabase backend
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("[APNs] Device token: \(tokenString)")

        // Forward to Capacitor (handles Firebase / custom plugins)
        NotificationCenter.default.post(
            name: .capacitorDidRegisterForRemoteNotifications,
            object: deviceToken
        )

        // Save token to Supabase for this user
        Task {
            await SupabasePushService.shared.savePushToken(tokenString)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[APNs] Registration failed: \(error.localizedDescription)")
        NotificationCenter.default.post(
            name: .capacitorDidFailToRegisterForRemoteNotifications,
            object: error
        )
    }

    // MARK: Deep Linking
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // e.g. sportspulse://match/liv-vs-byn-2025
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        // Universal Links support
        return ApplicationDelegateProxy.shared.application(
            application,
            continue: userActivity,
            restorationHandler: restorationHandler
        )
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {

    // Show notification while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    // Handle notification tap → deep link into app
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        // Extract deep link from payload: { "deepLink": "match/liv-vs-byn" }
        if let deepLink = userInfo["deepLink"] as? String {
            NotificationDeepLinkRouter.shared.navigate(to: deepLink)
        }

        // Forward to Capacitor push plugin
        NotificationCenter.default.post(
            name: Notification.Name.capacitorNotificationActionPerformed,
            object: response
        )

        completionHandler()
    }
}

// MARK: - Supabase Push Token Service
actor SupabasePushService {
    static let shared = SupabasePushService()

    func savePushToken(_ token: String) async {
        // POST to your Supabase Edge Function or table
        guard let url = URL(string: "\(Config.supabaseURL)/functions/v1/save-push-token") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(["token": token, "platform": "ios"])
        _ = try? await URLSession.shared.data(for: request)
    }
}

// MARK: - Deep Link Router
class NotificationDeepLinkRouter {
    static let shared = NotificationDeepLinkRouter()

    func navigate(to path: String) {
        // Post to JS layer via Capacitor bridge
        // e.g. "match/liv-vs-byn" → opens match page in Next.js app
        let js = "window.dispatchEvent(new CustomEvent('deepLink', { detail: '\(path)' }))"
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name("CAPBridgeJavaScriptExecute"),
                object: js
            )
        }
    }
}

// MARK: - Config (replace with your values / use .xcconfig)
enum Config {
    static let supabaseURL = "https://YOUR_PROJECT.supabase.co"
    static let supabaseAnonKey = "YOUR_ANON_KEY"
}
