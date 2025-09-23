import 'package:get/get.dart';
import 'package:flutter/services.dart';

class DashboardCtrl extends GetxController {
  var currentIndex = 0.obs;

  void changeTabIndex(int index) {
    HapticFeedback.lightImpact();
    currentIndex.value = index;
  }
}
