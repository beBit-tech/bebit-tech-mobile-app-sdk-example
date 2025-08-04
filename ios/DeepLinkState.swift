import Combine

class DeepLinkState: ObservableObject {
    @Published var selectedTab: Tab = .home
    @Published var showDeepLink: Bool = false

    enum Tab {
        case home, cart, webview
    }
}
