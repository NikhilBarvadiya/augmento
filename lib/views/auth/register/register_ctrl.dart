import 'package:augmento/utils/routes/route_name.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class RegisterCtrl extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final contactPersonCtrl = TextEditingController();

  var isLoading = false.obs, isPasswordVisible = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    mobileCtrl.dispose();
    companyCtrl.dispose();
    contactPersonCtrl.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final request = {
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
        'mobile': mobileCtrl.text.trim(),
        'company': companyCtrl.text.trim(),
        'contactPerson': contactPersonCtrl.text.trim(),
      };
      dio.FormData formData = dio.FormData.fromMap(request);
      await _authService.register(formData);
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() => Get.toNamed(AppRouteNames.login);
}
