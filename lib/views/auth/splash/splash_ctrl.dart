import 'package:augmento/utils/config/session.dart';
import 'package:augmento/utils/routes/route_name.dart';
import 'package:augmento/utils/storage.dart';
import 'package:get/get.dart';
import 'package:new_version_plus/new_version_plus.dart';

class SplashCtrl extends GetxController {
  RxString localVersion = "1.0.0'".obs;

  @override
  void onInit() {
    verifyVersion();
    super.onInit();
  }

  void verifyVersion() async {
    try {
      NewVersionPlus newVersion = NewVersionPlus();
      final status = await newVersion.getVersionStatus();
      localVersion.value = status?.localVersion ?? "1.0.0";
      if (status != null && status.canUpdate) {
        newVersion.showUpdateDialog(
          context: Get.context!,
          versionStatus: status,
          dialogTitle: 'Update Available',
          dialogText: 'A new version of the app is available. Please update to continue.',
          updateButtonText: 'Update',
          allowDismissal: false,
        );
      } else {
        _navigateToHome();
      }
    } catch (e) {
      _navigateToHome();
    }
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    String token = await read(AppSession.token) ?? "";
    if (token.isNotEmpty) {
      Get.offAllNamed(AppRouteNames.dashboard);
    } else {
      Get.offAllNamed(AppRouteNames.login);
    }
  }
}
