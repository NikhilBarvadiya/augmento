import 'package:augmento/utils/routes/route_name.dart';
import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class RegisterCtrl extends GetxController {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final contactPersonCtrl = TextEditingController();

  var isLoading = false.obs, isPasswordVisible = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> register() async {
    if (emailCtrl.text.isEmpty) {
      return toaster.warning('Please enter your email');
    }
    if (!GetUtils.isEmail(emailCtrl.text)) {
      return toaster.warning('Please enter a valid email');
    }
    if (passwordCtrl.text.isEmpty) {
      return toaster.warning('Please enter your password');
    }
    if (passwordCtrl.text.length < 6) {
      return toaster.warning('Password must be at least 6 characters');
    }
    if (mobileCtrl.text.isNotEmpty && !GetUtils.isPhoneNumber(mobileCtrl.text)) {
      return toaster.warning('Please enter a valid mobile number');
    }
    if (companyCtrl.text.isEmpty) {
      return toaster.warning('Please enter your company name');
    }
    if (contactPersonCtrl.text.isEmpty) {
      return toaster.warning('Please enter the contact person\'s name');
    }
    isLoading.value = true;
    try {
      final request = {
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
        'mobile': mobileCtrl.text.isEmpty ? "9999999999" : mobileCtrl.text.trim(),
        'company': companyCtrl.text.trim(),
        'contactPerson': contactPersonCtrl.text.trim(),
      };
      dio.FormData formData = dio.FormData.fromMap(request);
      bool isCheck = await _authService.register(formData);
      if (isCheck == true) {
        Get.back();
        emailCtrl.clear();
        passwordCtrl.clear();
        mobileCtrl.clear();
        companyCtrl.clear();
        contactPersonCtrl.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() => Get.toNamed(AppRouteNames.login);
}
