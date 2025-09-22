import OmniSegmentKit
import SwiftUI

@main
struct ShopDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var deepLinkState = DeepLinkState()
    @State private var isUserLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if isUserLoggedIn {
                VStack {
                    ContentView()
                        .environmentObject(deepLinkState)
                        .onAppear {
                            delegate.deepLinkState = deepLinkState
                        }
                    PageKeyViewControllerWrapper() // Add the PageKeyViewController
                        .frame(height: 100) // Adjust the height as necessary
                }
            } else {
                LoginView(isUserLoggedIn: $isUserLoggedIn)
                    .onAppear {
                        delegate.deepLinkState = deepLinkState
                    }
            }
        }
    }
}
