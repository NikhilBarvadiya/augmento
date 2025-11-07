import 'package:augmento/utils/helper/helper.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:augmento/utils/config/session.dart';
import 'package:augmento/utils/storage.dart';
import 'package:augmento/views/auth/auth_service.dart';

class AccountCtrl extends GetxController with GetTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  final RxBool showCurrentPassword = false.obs;
  final RxBool showNewPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  final RxBool isUpdatingPassword = false.obs;
  final RxBool isProfileExpanded = false.obs;
  final RxBool isSecurityExpanded = false.obs;

  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    animationController.forward();
    loadUserData();
  }

  void loadUserData() {
    final user = read(AppSession.userData) ?? {};
    userData.value = user;
  }

  void togglePasswordVisibility(String field) {
    switch (field) {
      case 'current':
        showCurrentPassword.toggle();
        break;
      case 'new':
        showNewPassword.toggle();
        break;
      case 'confirm':
        showConfirmPassword.toggle();
        break;
    }
  }

  void toggleProfileExpansion() => isProfileExpanded.toggle();

  void toggleSecurityExpansion() => isSecurityExpanded.toggle();

  Future<void> updatePassword() async {
    if (!passwordFormKey.currentState!.validate()) return;
    try {
      final request = {'currentPassword': currentPasswordController.text.trim(), 'newPassword': newPasswordController.text.trim()};
      bool isCheck = await _authService.changePassword(request);
      if (isCheck == true) {
        isSecurityExpanded.value = false;
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      }
    } finally {
      isUpdatingPassword.value = false;
    }
  }

  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Confirm Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout from your account?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.find<AuthService>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: const Text('Are you sure you want to delete from your account?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // helper.launchURL("https://docs.google.com/forms/d/e/1FAIpQLSe_6UsyVHh5hX02k2N-uaAz26Kl9iTim2fTskkyppcthKmlDQ/viewform?pli=1");
              helper.launchURL("https://augmento.itfuturz.in/account-delete");
              Get.find<AuthService>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
