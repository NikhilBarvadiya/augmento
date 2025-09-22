import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordCtrl extends GetxController {
  final emailCtrl = TextEditingController();
  var isLoading = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }

  Future<void> resetPassword() async {
    if (emailCtrl.text.isEmpty) {
      return toaster.warning('Please enter your email');
    }
    if (!GetUtils.isEmail(emailCtrl.text)) {
      return toaster.warning('Please enter a valid email');
    }
    isLoading.value = true;
    try {
      await _authService.forgotPassword(emailCtrl.text.trim());
    } finally {
      isLoading.value = false;
    }
  }
}
