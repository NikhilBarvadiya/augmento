import 'package:augmento/utils/routes/route_name.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginCtrl extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  var isLoading = false.obs, isPasswordVisible = false.obs;
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final request = {'email': emailCtrl.text.trim(), 'password': passwordCtrl.text.trim()};
      await _authService.login(request);
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() => Get.toNamed(AppRouteNames.register);

  void goToForgotPassword() => Get.toNamed(AppRouteNames.forgotPassword);
}
