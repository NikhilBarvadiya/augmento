import 'package:augmento/utils/decoration.dart';
import 'package:augmento/utils/routes/route_name.dart';
import 'package:augmento/views/dashboard/tabs/account/account_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountCtrl controller = Get.put(AccountCtrl());
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildCompactAppBar(controller),
      body: FadeTransition(
        opacity: controller.fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Obx(() {
                    final user = controller.userData.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: decoration.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: decoration.colorScheme.primary.withOpacity(0.3), width: 1),
                          ),
                          child: const Icon(Icons.person, size: 30, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user['company'] ?? 'Company Name',
                          style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user['email'] ?? 'EmailId',
                          style: TextStyle(fontSize: 13, color: decoration.colorScheme.primary.withOpacity(0.8), fontWeight: FontWeight.w500),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                  _buildQuickStatsCard(controller),
                  const SizedBox(height: 16),
                  _buildExpandableProfileSection(controller),
                  const SizedBox(height: 16),
                  _buildExpandableSecuritySection(controller),
                  const SizedBox(height: 16),
                  _buildLogoutCard(controller),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCompactAppBar(AccountCtrl controller) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: decoration.colorScheme.primary,
      title: const Text(
        'Account',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard(AccountCtrl controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.person_outline, 'Profile', 'Complete', const Color(0xFF3B82F6)),
          _buildStatDivider(),
          _buildStatItem(Icons.security, 'Security', 'Active', const Color(0xFF10B981)),
          _buildStatDivider(),
          _buildStatItem(Icons.settings, 'Settings', '5 Items', const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String subtitle, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
        ),
        Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 40, width: 1, color: const Color(0xFFF1F5F9));
  }

  Widget _buildExpandableProfileSection(AccountCtrl controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Obx(() {
            return ListTile(
              contentPadding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
              shape: RoundedRectangleBorder(borderRadius: controller.isProfileExpanded.value == true ? decoration.singleBorderRadius([1, 2], 16.0) : BorderRadius.circular(16)),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.person_outline, color: Color(0xFF3B82F6), size: 20),
              ),
              title: const Text(
                'Profile Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
              subtitle: const Text('View and manage your profile_edit details', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              trailing: Obx(() => Icon(controller.isProfileExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFF64748B))),
              onTap: () {
                HapticFeedback.lightImpact();
                controller.toggleProfileExpansion();
              },
            );
          }),
          Obx(() {
            if (!controller.isProfileExpanded.value) return const SizedBox.shrink();
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildMiniProfileDetails(controller),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMiniProfileDetails(AccountCtrl controller) {
    return Obx(() {
      final user = controller.userData.value;
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMiniProfileItem('Email', user['email'] ?? 'Not provided'),
            const SizedBox(height: 12),
            _buildMiniProfileItem('Mobile', user['mobile'] ?? 'Not provided'),
            const SizedBox(height: 12),
            _buildMiniProfileItem('Designation', user['designation'] ?? 'Not provided'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Row(
                spacing: 10.0,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Get.toNamed(AppRouteNames.profileDetails);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: decoration.colorScheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'View Profile',
                        style: TextStyle(color: decoration.colorScheme.primary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Get.toNamed(AppRouteNames.profileEdit);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: decoration.colorScheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(color: decoration.colorScheme.primary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMiniProfileItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableSecuritySection(AccountCtrl controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Obx(() {
            return ListTile(
              contentPadding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
              shape: RoundedRectangleBorder(borderRadius: controller.isSecurityExpanded.value == true ? decoration.singleBorderRadius([1, 2], 16.0) : BorderRadius.circular(16)),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.security, color: Color(0xFFEF4444), size: 20),
              ),
              title: const Text(
                'Security Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
              subtitle: const Text('Change password and security preferences', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              trailing: Obx(() => Icon(controller.isSecurityExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFF64748B))),
              onTap: () {
                HapticFeedback.lightImpact();
                controller.toggleSecurityExpansion();
              },
            );
          }),
          Obx(() {
            if (!controller.isSecurityExpanded.value) return const SizedBox.shrink();
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildPasswordChangeForm(controller),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPasswordChangeForm(AccountCtrl controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: controller.passwordFormKey,
        child: Column(
          children: [
            _buildPasswordField(
              controller: controller.currentPasswordController,
              label: 'Current Password',
              isVisible: controller.showCurrentPassword,
              onVisibilityToggle: () => controller.togglePasswordVisibility('current'),
              validator: (value) => value?.isEmpty == true ? 'Current password is required' : null,
            ),
            const SizedBox(height: 12),
            _buildPasswordField(
              controller: controller.newPasswordController,
              label: 'New Password',
              isVisible: controller.showNewPassword,
              onVisibilityToggle: () => controller.togglePasswordVisibility('new'),
              validator: (value) {
                if (value?.isEmpty == true) return 'New password is required';
                if (value!.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildPasswordField(
              controller: controller.confirmPasswordController,
              label: 'Confirm Password',
              isVisible: controller.showConfirmPassword,
              onVisibilityToggle: () => controller.togglePasswordVisibility('confirm'),
              validator: (value) {
                if (value?.isEmpty == true) return 'Please confirm your password';
                if (value != controller.newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isUpdatingPassword.value ? null : controller.updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: controller.isUpdatingPassword.value
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2))
                      : const Text('Update Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required RxBool isVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?) validator,
  }) {
    return Obx(
      () => TextFormField(
        controller: controller,
        obscureText: !isVisible.value,
        validator: validator,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFEF4444)),
          ),
          suffixIcon: IconButton(
            onPressed: onVisibilityToggle,
            icon: Icon(isVisible.value ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF64748B), size: 18),
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildLogoutCard(AccountCtrl controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
        ),
        subtitle: const Text('Sign out of your account', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        onTap: () => controller.showLogoutDialog(),
      ),
    );
  }
}
