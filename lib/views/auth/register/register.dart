import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/auth/register/register_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterCtrl>(
      init: RegisterCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: decoration.colorScheme.surface,
          body: SafeArea(
            child: Container(
              height: Get.height - MediaQuery.of(context).padding.top,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: decoration.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: decoration.colorScheme.outline.withOpacity(0.2)),
                            ),
                            child: IconButton(
                              onPressed: () => Get.back(),
                              icon: Icon(Icons.arrow_back_ios_rounded, color: decoration.colorScheme.onSurface, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [decoration.colorScheme.tertiary, decoration.colorScheme.tertiary.withOpacity(0.7)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: decoration.colorScheme.tertiary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: Icon(Icons.person_add_rounded, size: 40, color: decoration.colorScheme.onTertiary),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Create Account',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: decoration.colorScheme.onSurface),
                          ),
                          const SizedBox(height: 8),
                          Text('Join us today and get started', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: decoration.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Form(
                      key: ctrl.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildInputField(
                            context: context,
                            controller: ctrl.emailCtrl,
                            labelText: 'Email Address',
                            hintText: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!GetUtils.isEmail(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => _buildInputField(
                              context: context,
                              controller: ctrl.passwordCtrl,
                              labelText: 'Password',
                              hintText: 'Create a secure password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: !ctrl.isPasswordVisible.value,
                              suffixIcon: IconButton(
                                onPressed: ctrl.togglePasswordVisibility,
                                icon: Icon(ctrl.isPasswordVisible.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: decoration.colorScheme.onSurfaceVariant),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            context: context,
                            controller: ctrl.mobileCtrl,
                            labelText: 'Mobile Number',
                            hintText: 'Enter your phone number',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              if (!GetUtils.isPhoneNumber(value)) {
                                return 'Please enter a valid mobile number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            context: context,
                            controller: ctrl.companyCtrl,
                            labelText: 'Company Name',
                            hintText: 'Enter your company name',
                            prefixIcon: Icons.business_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your company name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            context: context,
                            controller: ctrl.contactPersonCtrl,
                            labelText: 'Contact Person',
                            hintText: 'Enter contact person name',
                            prefixIcon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the contact person\'s name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          Obx(
                            () => Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: ctrl.isLoading.value
                                    ? null
                                    : LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [decoration.colorScheme.tertiary, decoration.colorScheme.tertiary.withOpacity(0.8)],
                                      ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: ctrl.isLoading.value ? null : [BoxShadow(color: decoration.colorScheme.tertiary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                              ),
                              child: ElevatedButton(
                                onPressed: ctrl.isLoading.value ? null : ctrl.register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ctrl.isLoading.value ? decoration.colorScheme.surfaceContainerHighest : Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  minimumSize: const Size(double.infinity, 56),
                                ),
                                child: ctrl.isLoading.value
                                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: decoration.colorScheme.tertiary))
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.person_add_rounded, size: 20, color: decoration.colorScheme.onTertiary),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Create Account',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: decoration.colorScheme.onTertiary, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: decoration.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: decoration.colorScheme.outline.withOpacity(0.2)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: decoration.colorScheme.tertiary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Icon(Icons.security_rounded, size: 16, color: decoration.colorScheme.tertiary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'By creating an account, you agree to our Terms of Service and Privacy Policy',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: decoration.colorScheme.onSurfaceVariant, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: Container(height: 1, color: decoration.colorScheme.outline.withOpacity(0.2))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('or', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: decoration.colorScheme.onSurfaceVariant)),
                              ),
                              Expanded(child: Container(height: 1, color: decoration.colorScheme.outline.withOpacity(0.2))),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: decoration.colorScheme.onSurfaceVariant)),
                              TextButton(
                                onPressed: ctrl.goToLogin,
                                style: TextButton.styleFrom(foregroundColor: decoration.colorScheme.primary, padding: const EdgeInsets.symmetric(horizontal: 4)),
                                child: Text('Sign In', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: decoration.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: decoration.colorScheme.outline.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(prefixIcon, size: 20, color: decoration.colorScheme.primary),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          labelStyle: TextStyle(color: decoration.colorScheme.onSurfaceVariant),
        ),
        validator: validator,
      ),
    );
  }
}
