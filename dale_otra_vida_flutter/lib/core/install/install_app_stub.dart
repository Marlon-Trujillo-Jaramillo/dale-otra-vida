import 'install_app.dart';

InstallState installState() => InstallState.none;

Future<bool> promptInstall() async => false;

bool installBannerDismissed() => true;

void dismissInstallBanner() {}
