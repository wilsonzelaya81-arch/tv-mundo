import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var network: NetworkMonitor
    @StateObject private var model = WebViewModel()

    @State private var showSplash = true
    @State private var minimumSplashElapsed = false
    @State private var wasOffline = false
    @State private var showCellularNotice = false

    var body: some View {
        ZStack(alignment: .top) {
            Color("LaunchBackground").ignoresSafeArea()

            WebView(webView: model.webView)
                .ignoresSafeArea()
                .opacity(showSplash ? 0 : 1)
                .accessibilityHidden(showSplash)

            if showSplash {
                LoadingView(progress: model.progress, isOffline: !network.isConnected)
                    .transition(.opacity)
                    .zIndex(3)
            } else if case .failed(let message) = model.phase {
                OfflineView(reason: network.isConnected ? .error(message) : .offline) {
                    model.loadApp()
                }
                .transition(.opacity)
                .zIndex(2)
            }

            if !showSplash && !network.isConnected {
                OfflineBanner()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(4)
            } else if !showSplash && showCellularNotice {
                CellularBanner()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(4)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showSplash)
        .animation(.easeInOut(duration: 0.3), value: network.isConnected)
        .animation(.easeInOut(duration: 0.3), value: showCellularNotice)
        .task {
            model.loadApp()
            // Mínimo breve de pantalla de carga para evitar un parpadeo.
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            minimumSplashElapsed = true
            updateSplash()
            // Si la carga se demora demasiado, se muestra la app de todas formas.
            try? await Task.sleep(nanoseconds: 10_000_000_000)
            if showSplash { showSplash = false }
        }
        .onChange(of: model.phase) { _ in
            updateSplash()
        }
        .onChange(of: network.isConnected) { connected in
            if !connected {
                wasOffline = true
            } else if wasOffline {
                wasOffline = false
                // Al volver la conexión se recarga la lista de canales.
                model.reload()
            }
        }
        .onChange(of: network.kind) { kind in
            guard kind == .cellular else { return }
            showCellularNotice = true
            Task {
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                showCellularNotice = false
            }
        }
    }

    private func updateSplash() {
        guard minimumSplashElapsed else { return }
        if model.phase != .loading { showSplash = false }
    }
}
