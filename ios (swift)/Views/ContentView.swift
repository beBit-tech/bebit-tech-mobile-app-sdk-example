import Combine
import OmniSegmentKit  // BeBit Tech user behavior analytics SDK for event tracking
import SwiftUI

struct ContentView: View {
    @StateObject var cartManager = CartManager()
    @State private var showSaleModal = false
    @State private var isUserLoggedIn = false
    @State private var showingLoginScreen = false
    @State private var searchQuery = ""
    @EnvironmentObject var deepLinkState: DeepLinkState
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 20)]

    // Using @State, because struct can't mutating self.
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        ZStack {
            TabView(selection: $deepLinkState.selectedTab) {
                NavigationView {
                    ScrollView {
                        TextField("Search...", text: $searchQuery, onCommit: {
                            // OmniSegment SDK
                            // Track search events with query string and location context
                            // Event Tracking Guide: https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events
                            let event = OSGEvent.search(label: ["search_string": searchQuery])
                            event.location = "ProductListPage"
                            event.locationTitle = "SweaterApp Product List"
                            OmniSegment.trackEvent(event)
                        })
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal, 10)
                        .foregroundColor(.black)

                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(productList, id: \.id) { product in
                                NavigationLink(destination: ProductDetailView(product: product)) {
                                    ProductCard(product: product)
                                        .environmentObject(cartManager)
                                }
                            }
                        }
                        .padding()
                    }
                    .onAppear {
                        // Set current page for analytics tracking
                        // Page Tracking Guide: https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#set-current-page
                        OmniSegment.setCurrentPage("Home")

                        // Convert app products to OmniSegment product format for product impression tracking
                        let osgProducts = productList.enumerated().map { _, product in
                            let osgProduct = OSGProduct(id: product.id.uuidString, name: product.name)
                            osgProduct.price = NSNumber(value: product.price)
                            return osgProduct
                        }

                        // Track product impression event when products are displayed
                        // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
                        let event = OSGEvent.productImpression(osgProducts)
                        event.location = "ProductListPage"
                        event.locationTitle = "SweaterApp Product List"
                        OmniSegment.trackEvent(event)
                    }
                    .navigationTitle("Sweater Shop")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink {
                                CartView()
                                    .environmentObject(cartManager)
                            } label: {
                                CartButton(numberOfProducts: cartManager.products.count)
                            }
                        }
                    }
                }
                .tabItem {
                    Label("Shop", systemImage: "house")
                }
                .tag(DeepLinkState.Tab.home)

                WebViewPage()
                    .tabItem {
                        Label("WebView", systemImage: "globe")
                    }
                    .tag(DeepLinkState.Tab.webview)

                CartView()
                    .environmentObject(cartManager)
                    .tabItem {
                        Label("Cart", systemImage: "cart")
                    }
                    .tag(DeepLinkState.Tab.cart)
            }
            .onAppear {
                // Handle initial deep link if any
                handleDeepLink()
            }
            .onChange(of: deepLinkState.showDeepLink) { _ in
                handleDeepLink()
            }
        }
    }

    private func handleDeepLink() {
        if deepLinkState.showDeepLink {
            deepLinkState.showDeepLink = false
            deepLinkState.selectedTab = deepLinkState.selectedTab
        }
    }
}

struct SaleModalView: View {
    @Binding var showModal: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image("sale")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 200)
                .cornerRadius(15)
                .shadow(radius: 10)

            Button(action: {
                showModal = false
            }) {
                Image(systemName: "xmark.circle.fill") // System close icon
                    .font(.title)
                    .foregroundColor(.gray)
            }
            .padding([.top, .trailing], 10)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DeepLinkState())
    }
}
