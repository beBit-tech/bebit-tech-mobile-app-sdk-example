import FirebaseCore
import FirebaseMessaging
import OmniSegmentKit  // BeBit Tech user behavior analytics SDK - Main SDK for tracking user actions and events
import SwiftUI
import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    var window: UIWindow?
    var deepLinkState: DeepLinkState?

    func application(_: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        let omniSegmentInstance = OmniSegment()

        // MARK: - OmniSegmentKit SDK Initialization
        // Complete setup process for BeBit Tech's OmniSegmentKit analytics SDK
        // Installation Guide: https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Installation
        // Enable debug logs and initialize with API key and TID
        // Please modify the key and tid from your omnisegment organization setting
        // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki#1-debug-logs-and-sdk-initialization
        OmniSegment.enableDebugLogs()
        OmniSegment.initialize("XXXXX-XXXX-XXXX-XXXX-XXXX", tid: "OA-xxxx")

        // Set application metadata for analytics identification
        // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events
        OmniSegment.setAppName("test-app")
        OmniSegment.setBundleId("test-BundleId")
        OmniSegment.setBundleVersion("test-20240510")
        if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
            OmniSegment.setDeviceId(deviceId)
            print("deviceId: \(deviceId)")
        } else {
            OmniSegment.setDeviceId("test-DeviceId")
        }
        // MARK: -

        registerForPushNotifications()
        UNUserNotificationCenter.current().delegate = self

        if let url = launchOptions?[.url] as? URL {
            handleDeepLink(url)
        }
        // Initialize the window
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainViewController = PageKeyViewController() // Use your custom view controller
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()

        return true
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
            }
    }

    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    // MARK: - Firebase FCM Token & Event Tracking
    // Handle FCM token registration and track app open events
    // FCM Token Setup: https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#set-firebase-cloud-messaging-token
    func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM registration token: \(fcmToken ?? "")")
        if let fcmToken = fcmToken {
            // Provide FCM token for push analytics
            OmniSegment.setFCMToken(fcmToken)
            // Track app open
            // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
            OmniSegment.trackEvent(OSGEvent.appOpen())
        } else {
            // Track app open
            // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
            OmniSegment.trackEvent(OSGEvent.appOpen())
        }
    }
    // MARK: -

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
        // Track app open despite notification failure
        OmniSegment.trackEvent(OSGEvent.appOpen())
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("Received notification while app is in foreground: \(notification.request.content.userInfo)")
        let userInfo = notification.request.content.userInfo
        if let omnisegmentData = userInfo["omnisegment_data"] {
            // Handle incoming push notifications and trigger app popups
            // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Workflow-triggered-app-popup-setup
            OmniSegment.handleNotification(userInfo: userInfo)
        } else {
            if #available(iOS 14.0, *) {
                completionHandler([.banner, .sound])
            } else {
                completionHandler([.alert, .sound])
            }
        }
    }

    func application(
        _: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if let omnisegmentData = userInfo["omnisegment_data"] {
            // Handle incoming push notifications and trigger app popups
            // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Workflow-triggered-app-popup-setup
            OmniSegment.handleNotification(userInfo: userInfo)
        }
        completionHandler(.newData)
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        handleNotification(userInfo)
        completionHandler()
    }

    private func handleNotification(_ userInfo: [AnyHashable: Any]) {
        if let destinationURL = userInfo["destination_url"] as? String,
           let trackingURL = userInfo["omnisegment_tracking_url"] as? String
        {
            // Call GET method for the tracking URL
            callTrackingURL(trackingURL)
            if let url = URL(string: destinationURL) {
                print("handleDeepLink: \(url)")
                handleDeepLink(url)
            } else {
                print("Failed to create URL from destination_url")
            }
        } else {
            print("Destination URL or tracking URL not found in user info")
        }
    }

    private func handleDeepLink(_ url: URL) {
        print("Before update: \(deepLinkState?.selectedTab ?? .home)")
        switch url.host {
        case "home":
            deepLinkState?.selectedTab = .home
        case "cart":
            deepLinkState?.selectedTab = .cart
        case "webview":
            deepLinkState?.selectedTab = .webview
        default:
            break
        }
        print("After update: \(deepLinkState?.selectedTab ?? .home)")
        DispatchQueue.main.async {
            self.deepLinkState?.showDeepLink = true
        }
    }

    private func callTrackingURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid tracking URL")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { _, _, error in
            if let error = error {
                print("Error calling tracking URL: \(error.localizedDescription)")
            } else {
                print("Successfully called tracking URL")
            }
        }
        task.resume()
    }
}
