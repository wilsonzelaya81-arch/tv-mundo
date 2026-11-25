import Foundation
import UIKit
import WebKit

/// Dueño del WKWebView que muestra la app web de TV Mundo incluida en el paquete.
final class WebViewModel: NSObject, ObservableObject {
    enum Phase: Equatable {
        case loading
        case ready
        case failed(String)
    }

    @Published private(set) var phase: Phase = .loading
    @Published private(set) var progress: Double = 0

    let webView: WKWebView

    private var progressObservation: NSKeyValueObservation?
    private let refreshControl = UIRefreshControl()
    private(set) var hasLoadedOnce = false

    override init() {
        let config = WKWebViewConfiguration()

        // Reproducción multimedia
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsPictureInPictureMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true
        config.websiteDataStore = .default() // conserva favoritos y recientes (localStorage)
        config.applicationNameForUserAgent = "TVMundoApp/1.0"
        if #available(iOS 16.4, *) {
            config.preferences.isElementFullscreenEnabled = true
        }

        // Marca la página para que sepa que corre dentro de la app nativa.
        let marker = WKUserScript(
            source: "document.documentElement.classList.add('native-ios');window.TVMundoNative=true;",
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(marker)

        webView = WKWebView(frame: .zero, configuration: config)
        super.init()

        let background = UIColor(named: "LaunchBackground") ?? .black
        webView.isOpaque = false
        webView.backgroundColor = background
        webView.scrollView.backgroundColor = background
        // La página ya respeta las zonas seguras con env(safe-area-inset-*).
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsLinkPreview = false
        webView.navigationDelegate = self
        webView.uiDelegate = self

        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif

        refreshControl.tintColor = UIColor(named: "AccentColor")
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl

        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            let value = webView.estimatedProgress
            DispatchQueue.main.async { self?.progress = value }
        }
    }

    deinit {
        progressObservation?.invalidate()
    }

    // MARK: - Acciones

    func loadApp() {
        guard let index = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Web") else {
            phase = .failed("No se encontró el contenido de la app en el paquete.")
            return
        }
        phase = .loading
        webView.loadFileURL(index, allowingReadAccessTo: index.deletingLastPathComponent())
    }

    /// Vuelve a cargar la página (y con ella la lista de canales).
    func reload() {
        if webView.url == nil {
            loadApp()
        } else {
            if !hasLoadedOnce { phase = .loading }
            webView.reload()
        }
    }

    func pauseMedia() {
        webView.pauseAllMediaPlayback(completionHandler: nil)
    }

    @objc private func handlePullToRefresh() {
        reload()
    }

    private func finishRefreshing() {
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }
    }

    private func isInternal(_ url: URL) -> Bool {
        url.isFileURL || url.scheme == "about" || url.scheme == "blob" || url.scheme == "data"
    }

    private func openExternally(_ url: URL) {
        guard let scheme = url.scheme?.lowercased(), ["http", "https", "mailto", "tel"].contains(scheme) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - WKNavigationDelegate

extension WebViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        let isMainFrame = navigationAction.targetFrame?.isMainFrame ?? true
        if isMainFrame && !isInternal(url) {
            // Los enlaces externos se abren en Safari, la app se queda en su página.
            openExternally(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hasLoadedOnce = true
        phase = .ready
        finishRefreshing()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handle(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handle(error)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // iOS puede cerrar el proceso web por memoria; se recupera solo.
        reload()
    }

    private func handle(_ error: Error) {
        finishRefreshing()
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled { return }
        if nsError.domain == "WebKitErrorDomain" && nsError.code == 102 { return } // frame load interrupted
        phase = .failed(nsError.localizedDescription)
    }
}

// MARK: - WKUIDelegate

extension WebViewModel: WKUIDelegate {
    // target="_blank" y window.open: se abren en Safari.
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url { openExternally(url) }
        return nil
    }

    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
