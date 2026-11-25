import Foundation
import Network

/// Observa el estado de la conexión a internet (Wi-Fi, datos móviles o sin red).
final class NetworkMonitor: ObservableObject {
    enum Kind: Equatable {
        case wifi, cellular, wired, other, none
    }

    @Published private(set) var isConnected = true
    @Published private(set) var kind: Kind = .other
    /// true cuando la red es costosa (datos móviles o punto de acceso personal).
    @Published private(set) var isExpensive = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.wilsonzelaya.tvmundo.network")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            let kind: Kind
            if !connected {
                kind = .none
            } else if path.usesInterfaceType(.wifi) {
                kind = .wifi
            } else if path.usesInterfaceType(.cellular) {
                kind = .cellular
            } else if path.usesInterfaceType(.wiredEthernet) {
                kind = .wired
            } else {
                kind = .other
            }
            let expensive = path.isExpensive
            DispatchQueue.main.async {
                guard let self else { return }
                if self.isConnected != connected { self.isConnected = connected }
                if self.kind != kind { self.kind = kind }
                if self.isExpensive != expensive { self.isExpensive = expensive }
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
