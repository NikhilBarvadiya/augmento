import 'package:augmento/views/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordCtrl extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  var isLoading = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      await _authService.forgotPassword(emailController.text.trim());
    } finally {
      isLoading.value = false;
    }
  }
}
