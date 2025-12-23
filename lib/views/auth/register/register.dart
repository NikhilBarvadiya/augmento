import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/auth/register/register_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with SingleTickerProviderStateMixin {
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
    return GetBuilder<RegisterCtrl>(
      init: RegisterCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: decoration.colorScheme.surface,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [decoration.colorScheme.primary.withOpacity(0.1), decoration.colorScheme.primary.withOpacity(0.0)]),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150,
                  left: -100,
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [decoration.colorScheme.primaryContainer.withOpacity(0.15), decoration.colorScheme.primaryContainer.withOpacity(0.0)]),
                    ),
                  ),
                ),
                SingleChildScrollView(
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
                            const SizedBox(height: 40),
                            _buildEmailField(context, ctrl),
                            const SizedBox(height: 20),
                            _buildPasswordField(context, ctrl),
                            const SizedBox(height: 20),
                            _buildMobileField(context, ctrl),
                            const SizedBox(height: 20),
                            _buildCompanyField(context, ctrl),
                            const SizedBox(height: 20),
                            _buildContactPersonField(context, ctrl),
                            const SizedBox(height: 32),
                            _buildRegisterButton(context, ctrl),
                            const SizedBox(height: 24),
                            _buildTermsBox(context),
                            const SizedBox(height: 32),
                            _buildDivider(context),
                            const SizedBox(height: 24),
                            _buildSignInLink(context, ctrl),
                            const SizedBox(height: 32),
                          ],
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
            child: Icon(Icons.person_add_rounded, size: 48, color: decoration.colorScheme.onPrimary),
          ),
          const SizedBox(height: 32),
          Text(
            'Create Account',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: decoration.colorScheme.onSurface, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Join us today and get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13, color: decoration.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(BuildContext context, RegisterCtrl ctrl) {
    return _buildInputField(context: context, label: 'Email Address', hint: 'your.email@example.com', icon: Icons.email_outlined, controller: ctrl.emailCtrl, keyboardType: TextInputType.emailAddress);
  }

  Widget _buildPasswordField(BuildContext context, RegisterCtrl ctrl) {
    return Obx(
      () => _buildInputField(
        context: context,
        label: 'Password',
        hint: '••••••••',
        icon: Icons.lock_outline_rounded,
        controller: ctrl.passwordCtrl,
        obscureText: !ctrl.isPasswordVisible.value,
        suffixIcon: IconButton(
          onPressed: ctrl.togglePasswordVisibility,
          icon: Icon(ctrl.isPasswordVisible.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: decoration.colorScheme.onSurfaceVariant, size: 22),
        ).paddingOnly(right: 8),
      ),
    );
  }

  Widget _buildMobileField(BuildContext context, RegisterCtrl ctrl) {
    return _buildInputField(
      context: context,
      label: 'Mobile Number',
      hint: '+91 98765 43210',
      icon: Icons.phone_outlined,
      controller: ctrl.mobileCtrl,
      keyboardType: TextInputType.numberWithOptions(signed: true),
      maxLength: 10,
    );
  }

  Widget _buildCompanyField(BuildContext context, RegisterCtrl ctrl) {
    return _buildInputField(context: context, label: 'Company Name', hint: 'Your Company Ltd.', icon: Icons.business_outlined, controller: ctrl.companyCtrl);
  }

  Widget _buildContactPersonField(BuildContext context, RegisterCtrl ctrl) {
    return _buildInputField(context: context, label: 'Contact Person', hint: 'John Doe', icon: Icons.person_outline_rounded, controller: ctrl.contactPersonCtrl);
  }

  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
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
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLength: maxLength,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13, color: decoration.colorScheme.onSurface),
            decoration: InputDecoration(
              counterText: "",
              hintText: hint,
              hintStyle: TextStyle(fontSize: 13, letterSpacing: 0.5, color: decoration.colorScheme.onSurfaceVariant.withOpacity(0.5)),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(icon, size: 22, color: decoration.colorScheme.primary),
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context, RegisterCtrl ctrl) {
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
          onPressed: ctrl.isLoading.value ? null : ctrl.register,
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
                    const Icon(Icons.person_add_rounded, size: 20, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTermsBox(BuildContext context) {
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
            child: Icon(Icons.security_rounded, size: 20, color: decoration.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your data is secure',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: decoration.colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: decoration.colorScheme.onSurfaceVariant, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, decoration.colorScheme.outline.withOpacity(0.2)])),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'or',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: decoration.colorScheme.onSurfaceVariant.withOpacity(0.7), fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [decoration.colorScheme.outline.withOpacity(0.2), Colors.transparent])),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInLink(BuildContext context, RegisterCtrl ctrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: decoration.colorScheme.onSurfaceVariant)),
        TextButton(
          onPressed: ctrl.goToLogin,
          style: TextButton.styleFrom(foregroundColor: decoration.colorScheme.primary, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
          child: Text(
            'Sign In',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: decoration.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
