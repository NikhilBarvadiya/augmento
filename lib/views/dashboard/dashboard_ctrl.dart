import 'package:augmento/utils/routes/route_name.dart';
import 'package:augmento/utils/storage.dart';
import 'package:augmento/views/splash/splash_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardCtrl extends GetxController {
  @override
  Future<void> onInit() async {
    await clearStorage();
    Get.offNamedUntil(AppRouteNames.login, (Route<dynamic> route) => false);
    // Get.put(SplashCtrl(), permanent: true).onReady();
    super.onInit();
  }
}
