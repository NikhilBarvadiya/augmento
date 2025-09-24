import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/auth/login/login_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginCtrl>(
      init: LoginCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: decoration.colorScheme.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                height: Get.height - MediaQuery.of(context).padding.top,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.7)]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: Icon(Icons.login_rounded, size: 40, color: decoration.colorScheme.onPrimary),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: decoration.colorScheme.onSurface),
                          ),
                          const SizedBox(height: 8),
                          Text('Sign in to your account', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: decoration.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: decoration.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: decoration.colorScheme.outline.withOpacity(0.2)),
                            ),
                            child: TextFormField(
                              controller: ctrl.emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                hintText: 'Enter your email',
                                errorText: null,
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Icon(Icons.email_outlined, size: 20, color: decoration.colorScheme.primary),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                labelStyle: TextStyle(color: decoration.colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => Container(
                              decoration: BoxDecoration(
                                color: decoration.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: decoration.colorScheme.outline.withOpacity(0.2)),
                              ),
                              child: TextFormField(
                                controller: ctrl.passwordCtrl,
                                obscureText: !ctrl.isPasswordVisible.value,
                                style: Theme.of(context).textTheme.bodyLarge,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(12),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Icon(Icons.lock_outline, size: 20, color: decoration.colorScheme.primary),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: ctrl.togglePasswordVisibility,
                                    icon: Icon(ctrl.isPasswordVisible.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: decoration.colorScheme.onSurfaceVariant),
                                  ).paddingOnly(right: 5),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                  labelStyle: TextStyle(color: decoration.colorScheme.onSurfaceVariant),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: ctrl.goToForgotPassword,
                              style: TextButton.styleFrom(foregroundColor: decoration.colorScheme.primary),
                              child: Text('Forgot Password?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            ),
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
                                        colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8)],
                                      ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: ctrl.isLoading.value ? null : [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                              ),
                              child: ElevatedButton(
                                onPressed: ctrl.isLoading.value ? null : ctrl.login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ctrl.isLoading.value ? decoration.colorScheme.surfaceContainerHighest : Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  minimumSize: const Size(double.infinity, 56),
                                ),
                                child: ctrl.isLoading.value
                                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: decoration.colorScheme.primary))
                                    : Text(
                                        'Sign In',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: decoration.colorScheme.onPrimary, fontWeight: FontWeight.bold),
                                      ),
                              ),
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
                              Text("Don't have an account? ", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: decoration.colorScheme.onSurfaceVariant)),
                              TextButton(
                                onPressed: ctrl.goToRegister,
                                style: TextButton.styleFrom(foregroundColor: decoration.colorScheme.primary, padding: const EdgeInsets.symmetric(horizontal: 4)),
                                child: Text('Create Account', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text('© 2024 Augmento. All rights reserved.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: decoration.colorScheme.onSurfaceVariant.withOpacity(0.6))),
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
}
