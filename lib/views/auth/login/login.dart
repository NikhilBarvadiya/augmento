import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/auth/login/login_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginCtrl>(
      init: LoginCtrl(),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 40),
                              _buildHeader(context),
                              const SizedBox(height: 48),
                              _buildEmailField(context, ctrl),
                              const SizedBox(height: 20),
                              _buildPasswordField(context, ctrl),
                              const SizedBox(height: 12),
                              _buildForgotPassword(context, ctrl),
                              const SizedBox(height: 32),
                              _buildLoginButton(context, ctrl),
                              const SizedBox(height: 32),
                              _buildDivider(context),
                              const SizedBox(height: 24),
                              _buildSignUpLink(context, ctrl),
                              const SizedBox(height: 40),
                              _buildFooter(context),
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
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10), spreadRadius: -5)],
              image: DecorationImage(image: AssetImage('assets/applogo.png'), fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: decoration.colorScheme.onSurface, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue to Augmento Staff',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13, color: decoration.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context, LoginCtrl ctrl) {
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
              hintStyle: TextStyle(fontSize: 13, letterSpacing: .5, color: decoration.colorScheme.onSurfaceVariant.withOpacity(0.5)),
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

  Widget _buildPasswordField(BuildContext context, LoginCtrl ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Password',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: decoration.colorScheme.onSurface),
          ),
        ),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: decoration.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: decoration.colorScheme.outline.withOpacity(0.1), width: 1),
            ),
            child: TextFormField(
              controller: ctrl.passwordCtrl,
              obscureText: !ctrl.isPasswordVisible.value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13, color: decoration.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: TextStyle(fontSize: 13, letterSpacing: .5, color: decoration.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Icon(Icons.lock_outline_rounded, size: 22, color: decoration.colorScheme.primary),
                ),
                suffixIcon: IconButton(
                  onPressed: ctrl.togglePasswordVisibility,
                  icon: Icon(ctrl.isPasswordVisible.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: decoration.colorScheme.onSurfaceVariant, size: 22),
                ).paddingOnly(right: 8),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword(BuildContext context, LoginCtrl ctrl) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: ctrl.goToForgotPassword,
        style: TextButton.styleFrom(foregroundColor: decoration.colorScheme.primary, padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8)),
        child: Text(
          'Forgot Password?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: decoration.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, LoginCtrl ctrl) {
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
          onPressed: ctrl.isLoading.value ? null : ctrl.login,
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
                    Text(
                      'Sign In',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                  ],
                ),
        ),
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

  Widget _buildSignUpLink(BuildContext context, LoginCtrl ctrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: decoration.colorScheme.onSurfaceVariant)),
        TextButton(
          onPressed: ctrl.goToRegister,
          style: TextButton.styleFrom(foregroundColor: decoration.colorScheme.primary, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
          child: Text(
            'Create Account',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: decoration.colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Text(
        '© 2025 Augmento Staff. All rights reserved.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: decoration.colorScheme.onSurfaceVariant.withOpacity(0.5), fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }
}
