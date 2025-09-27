import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class DashboardCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  var currentIndex = 0.obs;
  var counts = {}.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () async => await fetchDashboardData());
  }

  void changeTabIndex(int index) {
    HapticFeedback.lightImpact();
    currentIndex.value = index;
  }

  Future<void> fetchDashboardData() async {
    try {
      final response = await _authService.getDashboardData();
      if (response.isNotEmpty) {
        counts.value = response['counts'] ?? {};
      }
    } catch (e) {
      toaster.error("Error: $e");
    }
  }
}
