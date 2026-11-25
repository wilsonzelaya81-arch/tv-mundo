import SwiftUI

/// Pantalla de carga que se muestra mientras arranca la app web.
struct LoadingView: View {
    var progress: Double
    var isOffline: Bool

    @State private var pulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var logoSize: CGFloat { sizeClass == .regular ? 180 : 132 }

    var body: some View {
        ZStack {
            Color("LaunchBackground").ignoresSafeArea()

            VStack(spacing: 22) {
                Image("Logo")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: logoSize, height: logoSize)
                    .clipShape(RoundedRectangle(cornerRadius: logoSize * 0.22, style: .continuous))
                    .shadow(color: Color("AccentColor").opacity(0.35), radius: pulse ? 28 : 12)
                    .scaleEffect(pulse ? 1.03 : 0.97)
                    .accessibilityHidden(true)

                (Text("TV ").foregroundColor(.white) + Text("Mundo").foregroundColor(Color("AccentColor")))
                    .font(.system(size: sizeClass == .regular ? 44 : 34, weight: .bold, design: .rounded))

                Text(isOffline ? "Esperando conexión a internet…" : "Cargando canales en vivo…")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                ProgressView(value: max(progress, 0.05))
                    .progressViewStyle(.linear)
                    .tint(Color("AccentColor"))
                    .frame(width: sizeClass == .regular ? 280 : 200)
            }
            .padding()
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("TV Mundo cargando")
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(progress: 0.4, isOffline: false)
    }
}
