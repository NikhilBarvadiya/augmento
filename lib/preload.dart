import 'package:augmento/views/auth/auth_service.dart';
import 'package:get/get.dart';

Future<void> preload() async {
  await Get.putAsync(() => AuthService().init());
}
