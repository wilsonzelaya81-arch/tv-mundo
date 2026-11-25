import SwiftUI

/// Pantalla completa cuando la app no puede cargar (sin internet o error).
struct OfflineView: View {
    enum Reason: Equatable {
        case offline
        case error(String)
    }

    var reason: Reason
    var onRetry: () -> Void

    var body: some View {
        ZStack {
            Color("LaunchBackground").ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundColor(Color("AccentColor"))
                    .accessibilityHidden(true)
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
                Button(action: onRetry) {
                    Label("Reintentar", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .padding(.horizontal, 28)
                        .frame(minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("AccentColor"))
                .padding(.top, 8)
            }
            .padding(32)
        }
    }

    private var icon: String {
        switch reason {
        case .offline: return "wifi.slash"
        case .error: return "exclamationmark.triangle"
        }
    }

    private var title: String {
        switch reason {
        case .offline: return "Sin conexión a internet"
        case .error: return "No se pudo abrir TV Mundo"
        }
    }

    private var message: String {
        switch reason {
        case .offline:
            return "Conéctate a Wi-Fi o datos móviles para ver los canales en vivo. Tus favoritos siguen guardados."
        case .error(let detail):
            return detail
        }
    }
}

/// Aviso pequeño arriba de la pantalla cuando se pierde la conexión con la app ya abierta.
struct OfflineBanner: View {
    var body: some View {
        Label("Sin conexión. Los canales volverán al reconectar.", systemImage: "wifi.slash")
            .font(.footnote.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color(red: 0.92, green: 0.41, blue: 0.34)))
            .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
            .padding(.top, 8)
            .accessibilityAddTraits(.isStaticText)
    }
}

/// Aviso cuando se usan datos móviles (el video en vivo consume bastante).
struct CellularBanner: View {
    var body: some View {
        Label("Estás usando datos móviles", systemImage: "antenna.radiowaves.left.and.right")
            .font(.footnote.weight(.semibold))
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color(red: 0.96, green: 0.78, blue: 0.30)))
            .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
            .padding(.top, 8)
    }
}

struct OfflineView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineView(reason: .offline, onRetry: {})
    }
}
