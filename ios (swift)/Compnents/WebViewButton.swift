import OmniSegmentKit  // BeBit Tech analytics SDK for webview tracking and integration
import SwiftUI
import WebKit

struct WebViewButton: View {
    @State private var showWebView = false

    var body: some View {
        Button(action: {
            showWebView = true
        }) {
            Image(systemName: "arrow.right.circle")
            Text("前往 WebView")
                .bold()
        }
        .sheet(isPresented: $showWebView) {
            WebViewPage()
        }
    }
}

struct WebViewPage: View {
    var body: some View {
        WebView(url: URL(string: "https://bebit2.shoplineapp.com/")!)
            .edgesIgnoringSafeArea(.all)
            // Set current page for analytics tracking when webview appears
            .onAppear { OmniSegment.setCurrentPage("WebView") }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context _: Context) -> WKWebView {
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.applicationNameForUserAgent = "AppWebView"
        // OmniSegment SDK
        // Add OmniSegment content controller for web-app analytics integration
        // This enables tracking of user interactions within the webview
        // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#integrate-omnisegment-sdk-with-webview-pages
        webViewConfiguration.addOmniSegmentContentController()

        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        uiView.load(request)
    }
}

struct WebViewButton_Previews: PreviewProvider {
    static var previews: some View {
        WebViewButton()
    }
}
