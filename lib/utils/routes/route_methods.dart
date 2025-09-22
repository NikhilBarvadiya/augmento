import 'package:augmento/utils/routes/route_name.dart';
import 'package:augmento/views/auth/forgot_password/forgot_password.dart';
import 'package:augmento/views/auth/login/login.dart';
import 'package:augmento/views/auth/register/register.dart';
import 'package:augmento/views/no_internet.dart';
import 'package:augmento/views/splash/splash.dart';
import 'package:get/get.dart';

class AppRouteMethods {
  static GetPage<dynamic> getPage({required String name, required GetPageBuilder page, List<GetMiddleware>? middlewares}) {
    return GetPage(name: name, page: page, transition: Transition.topLevel, showCupertinoParallax: true, middlewares: middlewares ?? [], transitionDuration: 350.milliseconds);
  }

  static List<GetPage> pages = [
    getPage(name: AppRouteNames.splash, page: () => const Splash()),
    getPage(name: AppRouteNames.login, page: () => const Login()),
    getPage(name: AppRouteNames.register, page: () => const Register()),
    getPage(name: AppRouteNames.forgotPassword, page: () => const ForgotPassword()),
    getPage(name: AppRouteNames.noInternet, page: () => const NoInternet()),
    // getPage(name: AppRouteNames.dashboard, page: () => const Dashboard()),
  ];
}
