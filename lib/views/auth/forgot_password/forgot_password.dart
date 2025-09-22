import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/auth/forgot_password/forgot_password_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgotPasswordCtrl>(
      init: ForgotPasswordCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: decoration.colorScheme.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                height: Get.height - MediaQuery.of(context).padding.top,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Stack(
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
                    Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.7)],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                                ),
                                child: Icon(Icons.lock_reset_rounded, size: 50, color: decoration.colorScheme.onPrimary),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Forgot Password?',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: decoration.colorScheme.onSurface),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'No worries! Enter your email address and we\'ll send you a reset link',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: decoration.colorScheme.onSurfaceVariant, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
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
                                    hintText: 'Enter your registered email',
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(12),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: decoration.colorScheme.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Icon(Icons.email_outlined, size: 20, color: decoration.colorScheme.secondary),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                    labelStyle: TextStyle(color: decoration.colorScheme.onSurfaceVariant),
                                  ),
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
                                    onPressed: ctrl.isLoading.value ? null : ctrl.resetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ctrl.isLoading.value ? decoration.colorScheme.primary : Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      minimumSize: const Size(double.infinity, 56),
                                    ),
                                    child: ctrl.isLoading.value
                                        ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: decoration.colorScheme.secondary))
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.send_rounded, size: 20, color: decoration.colorScheme.onSecondary),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Send Reset Link',
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: decoration.colorScheme.onSecondary, fontWeight: FontWeight.bold),
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
                                  color: decoration.colorScheme.primaryContainer.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: decoration.colorScheme.primary.withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Icon(Icons.info_outline_rounded, size: 20, color: decoration.colorScheme.primary),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Check your spam folder if you don\'t receive the email within a few minutes',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: decoration.colorScheme.onPrimaryContainer, height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Remember your password? ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: decoration.colorScheme.onSurfaceVariant)),
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    style: TextButton.styleFrom(foregroundColor: decoration.colorScheme.primary, padding: const EdgeInsets.symmetric(horizontal: 4)),
                                    child: Text('Sign In', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text('Need help? Contact support', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: decoration.colorScheme.onSurfaceVariant.withOpacity(0.6))),
                        ),
                      ],
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
