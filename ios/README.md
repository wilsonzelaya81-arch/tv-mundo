# TV Mundo para iOS

App nativa SwiftUI para iPhone y iPad (iOS 16 o superior) que muestra el sitio web de TV Mundo dentro de un `WKWebView`.

## Abrir y ejecutar

1. En una Mac con Xcode 14.3 o superior (se recomienda Xcode 15), abre `ios/TVMundo.xcodeproj`.
2. Elige el esquema **TVMundo** y un simulador de iPhone o iPad, y pulsa ▶.
3. Para instalarla en tu propio iPhone: en el target **TVMundo → Signing & Capabilities**, elige tu **Team** (sirve un Apple ID gratuito) y, si hace falta, cambia el *Bundle Identifier* (`com.wilsonzelaya.tvmundo`) por uno único.

## Qué incluye

| Parte | Archivo |
|---|---|
| Arranque de la app y sesión de audio (suena con el iPhone en silencio, audio en segundo plano y PiP) | `TVMundoApp.swift` |
| Pantalla principal: pantalla de carga, errores y avisos de conexión | `ContentView.swift` |
| `WKWebView` configurado para video en línea, autoplay, Picture in Picture, AirPlay y pantalla completa | `WebViewModel.swift`, `WebView.swift` |
| Pantalla de carga con el logo | `LoadingView.swift` |
| Sin conexión, error con botón de reintento, aviso de datos móviles | `OfflineView.swift` |
| Monitor de red (Wi-Fi, datos móviles, sin conexión) | `NetworkMonitor.swift` |
| Íconos (los mismos del sitio web), colores y logo | `Assets.xcassets` |
| Copia del sitio web que carga la app | `TVMundo/Web/` |

**Comportamiento:**

- La web se carga desde el propio paquete, así que la app abre al instante aunque no haya internet. Solo la lista de canales y los videos necesitan conexión.
- Si se pierde la conexión aparece un aviso arriba. Al volver la conexión, la app recarga la lista sola.
- Puedes deslizar hacia abajo para recargar.
- Los enlaces externos se abren en Safari.
- Favoritos y recientes se guardan en el dispositivo.
- En iPad funciona en todas las orientaciones y en pantalla dividida. En iPhone funciona en vertical y horizontal.
- `NSAllowsArbitraryLoadsInWebContent` permite reproducir canales `http`, que en la versión web publicada quedan ocultos.

## Actualizar la web dentro de la app

Si cambias `index.html` u otro archivo del sitio en la raíz del repositorio, ejecuta:

```bash
ios/sync-web.sh
```

## Compilación automática

`.github/workflows/ios-build.yml` compila el proyecto con Xcode en macOS, sin firma, para simulador (Debug) y dispositivo (Release) en cada cambio. El resultado se ve en la pestaña **Actions** del repositorio.

## Publicar en el App Store

Hace falta una cuenta del Apple Developer Program (99 USD/año). Apple suele revisar con cuidado las apps que reproducen canales de terceros. Para publicarla conviene usar solo canales con permiso de redistribución, porque una app que solo envuelve un sitio web puede ser rechazada (guía 4.2).
