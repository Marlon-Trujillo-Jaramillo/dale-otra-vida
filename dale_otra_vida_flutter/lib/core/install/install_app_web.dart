import 'dart:js_interop';

import 'install_app.dart';

@JS('dovInstall')
external _DovInstall? get _dovInstall;

extension type _DovInstall(JSObject _) implements JSObject {
  external JSString state();
  external JSPromise<JSBoolean> prompt();
  external JSBoolean dismissed();
  external void dismiss();
}

InstallState installState() {
  switch (_dovInstall?.state().toDart) {
    case 'prompt':
      return InstallState.prompt;
    case 'ios':
      return InstallState.ios;
    case 'android':
      return InstallState.android;
    default:
      return InstallState.none;
  }
}

Future<bool> promptInstall() async {
  final install = _dovInstall;
  if (install == null) return false;
  return (await install.prompt().toDart).toDart;
}

bool installBannerDismissed() => _dovInstall?.dismissed().toDart ?? true;

void dismissInstallBanner() => _dovInstall?.dismiss();
