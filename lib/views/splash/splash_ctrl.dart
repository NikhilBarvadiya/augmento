import 'package:augmento/utils/config/session.dart';
import 'package:augmento/utils/routes/route_name.dart';
import 'package:augmento/utils/storage.dart';
import 'package:get/get.dart';
import 'package:new_version_plus/new_version_plus.dart';

class SplashCtrl extends GetxController {
  @override
  void onInit() {
    verifyVersion();
    super.onInit();
    // _navigateToHome();
  }

  void verifyVersion() async {
    NewVersionPlus newVersion = NewVersionPlus();
    final status = await newVersion.getVersionStatus();
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
