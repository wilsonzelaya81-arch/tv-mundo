import SwiftUI
import AVFoundation

@main
struct TVMundoApp: App {
    @StateObject private var network = NetworkMonitor()

    init() {
        // Permite que el audio de los canales suene aunque el iPhone esté en silencio,
        // y habilita Picture in Picture y audio en segundo plano.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .moviePlayback, options: [])
        try? session.setActive(true)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(network)
                .preferredColorScheme(.dark)
        }
    }
}
