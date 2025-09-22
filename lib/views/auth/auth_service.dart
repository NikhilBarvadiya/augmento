import 'package:augmento/utils/config/session.dart';
import 'package:augmento/utils/network/api_index.dart';
import 'package:augmento/utils/network/api_manager.dart';
import 'package:augmento/utils/routes/route_name.dart';
import 'package:augmento/utils/storage.dart';
import 'package:augmento/utils/toaster.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  Future<AuthService> init() async => this;
  final ApiManager _apiManager = ApiManager();

  Future<void> login(Map<String, dynamic> request) async {
    try {
      final response = await _apiManager.post(APIIndex.login, request);
      if (!response.success) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      await write(AppSession.token, response.data["accessToken"]);
      await write(AppSession.userData, response.data["vendor"]);
      Get.toNamed(AppRouteNames.dashboard);
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await _apiManager.post(APIIndex.forgotPassword, {"email": email});
      if (!response.success) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      toaster.success(response.message.toString().capitalizeFirst.toString());
      Get.back();
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<void> register(dynamic request) async {
    try {
      final response = await _apiManager.post(APIIndex.register, request);
      if (!response.success) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      toaster.success(response.message.toString().capitalizeFirst.toString());
      Get.back();
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }
}
