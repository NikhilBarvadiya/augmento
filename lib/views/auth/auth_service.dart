import 'package:augmento/utils/config/session.dart';
import 'package:augmento/utils/network/api_index.dart';
import 'package:augmento/utils/network/api_manager.dart';
import 'package:augmento/utils/routes/route_name.dart';
import 'package:augmento/utils/storage.dart';
import 'package:augmento/utils/toaster.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

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

  Future<bool> register(dynamic request) async {
    try {
      final response = await _apiManager.post(APIIndex.register, request);
      if (!response.success) {
        toaster.warning(response.message ?? 'Something went wrong');
        return false;
      }
      toaster.success(response.message.toString().capitalizeFirst.toString());
      return true;
    } catch (err) {
      toaster.error(err.toString());
      return false;
    }
  }

  Future<bool> changePassword(dynamic request) async {
    try {
      final response = await _apiManager.post(APIIndex.changePassword, request);
      if (!response.success) {
        toaster.warning(response.message ?? 'Something went wrong');
        return false;
      }
      toaster.success(response.message.toString().capitalizeFirst.toString());
      return true;
    } catch (err) {
      toaster.error(err.toString());
      return false;
    }
  }

  Future<bool> validateGST(String gst) async {
    try {
      final response = await _apiManager.post(APIIndex.validateGST, {"SGSTIN": gst});
      if (!response.success) {
        toaster.warning(response.message ?? 'Something went wrong');
        return false;
      }
      toaster.success(response.message.toString().capitalizeFirst.toString());
      return true;
    } catch (err) {
      toaster.error(err.toString());
      return false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data, PlatformFile? panCard, PlatformFile? avatar, List<PlatformFile> certificates) async {
    try {
      final formData = FormData.fromMap({...data, 'engagementModels': data['engagementModels'], 'timeZones': data['timeZones']});
      if (panCard != null) {
        formData.files.add(MapEntry('panCard', await MultipartFile.fromFile(panCard.path!, filename: panCard.name)));
      }
      if (avatar != null) {
        formData.files.add(MapEntry('avatar', await MultipartFile.fromFile(avatar.path!, filename: avatar.name)));
      }
      for (var cert in certificates) {
        formData.files.add(MapEntry('certificates', await MultipartFile.fromFile(cert.path!, filename: cert.name)));
      }
      final response = await _apiManager.post(APIIndex.updateProfile, formData);
      if (!response.success) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      final updatedUser = {...read(AppSession.userData) ?? {}, ...data};
      await write(AppSession.userData, updatedUser);
      toaster.success(response.message.toString().capitalizeFirst.toString());
      Get.back();
    } catch (err) {
      toaster.error(err.toString());
    }
  }

  Future<void> logout() async {
    await clearStorage();
    Get.offAllNamed(AppRouteNames.login);
  }
}
