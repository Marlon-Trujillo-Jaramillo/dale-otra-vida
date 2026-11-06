/// "Instalar app" support for the web build. Other platforms are already
/// installed apps, so every call there reports [InstallState.none].
library;

export 'install_app_stub.dart'
    if (dart.library.js_interop) 'install_app_web.dart';

/// How this browser lets the app be added to the home screen.
enum InstallState {
  /// Already installed, or the browser can't install web apps.
  none,

  /// The browser can show its own install dialog ([promptInstall]).
  prompt,

  /// iPhone/iPad: only through Share → "Agregar a pantalla de inicio".
  ios,

  /// Android without a ready dialog: through the browser menu.
  android,
}
