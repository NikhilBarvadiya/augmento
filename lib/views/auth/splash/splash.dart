import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/auth/splash/splash_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  late AnimationController _fadeController, _scaleController, _slideController;
  late Animation<double> _fadeAnimation, _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _scaleController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashCtrl>(
      init: SplashCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: decoration.colorScheme.primary,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.95), decoration.colorScheme.primaryContainer.withOpacity(0.9)],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
                    child: AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value * 0.1,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    left: -80,
                    child: AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value * 0.08,
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 15), spreadRadius: -5)],
                                  image: DecorationImage(image: AssetImage('assets/applogo.png'), fit: BoxFit.cover),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        SlideTransition(
                          position: _slideAnimation,
                          child: AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _fadeAnimation.value,
                                child: Column(
                                  children: [
                                    const Text(
                                      'Augmento',
                                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5, height: 1.2),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'STAFF',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.9), letterSpacing: 6.0),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value * 0.85,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Organize Your Workflow',
                                  style: TextStyle(fontSize: 14, color: Colors.white, letterSpacing: 1.0, fontWeight: FontWeight.w400),
                                ),
                              ),
                            );
                          },
                        ),
                        const Spacer(flex: 2),
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: Column(
                                children: [
                                  SizedBox(width: 35, height: 35, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.9)))),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading...',
                                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7), letterSpacing: 1.0, fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Spacer(flex: 1),
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value * 0.5,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Obx(() {
                                  return Text(
                                    'Version ${ctrl.localVersion.value}',
                                    style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6), letterSpacing: 0.5, fontWeight: FontWeight.w300),
                                  );
                                }),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
