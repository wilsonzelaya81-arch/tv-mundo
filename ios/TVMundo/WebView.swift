import SwiftUI
import WebKit

/// Puente SwiftUI → WKWebView. El WKWebView vive en WebViewModel para que no se recree.
struct WebView: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
