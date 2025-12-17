import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/auth/forgot_password/forgot_password_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation, _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgotPasswordCtrl>(
      init: ForgotPasswordCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: decoration.colorScheme.surface,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [decoration.colorScheme.primary.withOpacity(0.08), decoration.colorScheme.primary.withOpacity(0.0)]),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -80,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [decoration.colorScheme.primaryContainer.withOpacity(0.12), decoration.colorScheme.primaryContainer.withOpacity(0.0)]),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: double.infinity),
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 20),
                              _buildHeader(context),
                              const SizedBox(height: 48),
                              _buildEmailField(context, ctrl),
                              const SizedBox(height: 32),
                              _buildSubmitButton(context, ctrl),
                              const SizedBox(height: 24),
                              _buildInfoBox(context),
                              const SizedBox(height: 32),
                              _buildBackToLoginLink(context),
                              const SizedBox(height: 24),
                              _buildSupportLink(context),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10), spreadRadius: -5)],
            ),
            child: Icon(Icons.lock_reset_rounded, size: 48, color: decoration.colorScheme.onPrimary),
          ),
          const SizedBox(height: 32),
          Text(
            'Forgot Password?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: decoration.colorScheme.onSurface, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'No worries! Enter your email address and we\'ll send you instructions to reset your password',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13, color: decoration.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(BuildContext context, ForgotPasswordCtrl ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Email Address',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: decoration.colorScheme.onSurface),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: decoration.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: decoration.colorScheme.outline.withOpacity(0.1), width: 1),
          ),
          child: TextFormField(
            controller: ctrl.emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13, color: decoration.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'your.email@example.com',
              hintStyle: TextStyle(fontSize: 13, letterSpacing: 0.5, color: decoration.colorScheme.onSurfaceVariant.withOpacity(0.5)),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(Icons.email_outlined, size: 22, color: decoration.colorScheme.primary),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, ForgotPasswordCtrl ctrl) {
    return Obx(
      () => Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: ctrl.isLoading.value
              ? null
              : LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.85)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: ctrl.isLoading.value ? null : [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10), spreadRadius: -5)],
        ),
        child: ElevatedButton(
          onPressed: ctrl.isLoading.value ? null : ctrl.resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: ctrl.isLoading.value ? decoration.colorScheme.surfaceContainerHighest : Colors.transparent,
            foregroundColor: decoration.colorScheme.onPrimary,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            minimumSize: const Size(double.infinity, 56),
          ),
          child: ctrl.isLoading.value
              ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: decoration.colorScheme.primary))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, size: 20, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Send Reset Link',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: decoration.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: decoration.colorScheme.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.info_outline_rounded, size: 20, color: decoration.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check your inbox',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: decoration.colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  'If you don\'t receive the email within a few minutes, check your spam folder',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: decoration.colorScheme.onSurfaceVariant, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackToLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Remember your password?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: decoration.colorScheme.onSurfaceVariant)),
        TextButton(
          onPressed: () => Get.close(1),
          style: TextButton.styleFrom(foregroundColor: decoration.colorScheme.primary, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
          child: Text(
            'Sign In',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: decoration.colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportLink(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          // Handle support navigation
          // You can add your support email or help page here
        },
        style: TextButton.styleFrom(foregroundColor: decoration.colorScheme.onSurfaceVariant, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.support_agent_rounded, size: 18, color: decoration.colorScheme.onSurfaceVariant.withOpacity(0.7)),
            const SizedBox(width: 6),
            Text('Need help? Contact support', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: decoration.colorScheme.onSurfaceVariant.withOpacity(0.7), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
