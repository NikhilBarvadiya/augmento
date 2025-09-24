import 'dart:convert';
import 'package:augmento/utils/config/session.dart';
import 'package:augmento/utils/network/api_index.dart';
import 'package:augmento/utils/network/api_manager.dart';
import 'package:augmento/utils/routes/route_name.dart';
import 'package:augmento/utils/storage.dart';
import 'package:augmento/utils/toaster.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  Future<AuthService> init() async => this;
  final ApiManager _apiManager = ApiManager();

  Future<void> login(Map<String, dynamic> request) async {
    try {
      final response = await _apiManager.post(APIIndex.login, request);
      if (!response.success || response.data == null) {
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
      if (!response.success || response.data == null) {
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
      if (!response.success || response.data == null) {
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
      if (!response.success || response.data == null) {
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
      if (!response.success || response.data == null) {
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
      final formData = dio.FormData.fromMap({
        ...data,
        'engagementModels': jsonEncode(data['engagementModels']),
        'timeZones': jsonEncode(data['timeZones']),
        "bankDetails": jsonEncode(data['bankDetails']),
      });
      if (panCard != null) {
        formData.files.add(MapEntry('panCard', await dio.MultipartFile.fromFile(panCard.path!, filename: panCard.name)));
      }
      if (avatar != null) {
        formData.files.add(MapEntry('avatar', await dio.MultipartFile.fromFile(avatar.path!, filename: avatar.name)));
      }
      for (var cert in certificates) {
        formData.files.add(MapEntry('certificates', await dio.MultipartFile.fromFile(cert.path!, filename: cert.name)));
      }
      final response = await _apiManager.post(APIIndex.updateProfile, formData);
      if (!response.success || response.data == null) {
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

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _apiManager.post(APIIndex.getCounts, {});
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Something went wrong');
        return {};
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> createCandidateProfile(Map<String, dynamic> candidates, PlatformFile? profileImage, PlatformFile? resume) async {
    try {
      final formData = dio.FormData.fromMap(candidates);
      if (profileImage != null) {
        formData.files.add(MapEntry('profileImage', await dio.MultipartFile.fromFile(profileImage.path!, filename: profileImage.name)));
      }
      if (resume != null) {
        formData.files.add(MapEntry('resume', await dio.MultipartFile.fromFile(resume.path!, filename: resume.name)));
      }
      String apiURL = candidates["id"] != null ? APIIndex.modifyCandidate : APIIndex.createCandidateProfile;
      final response = await _apiManager.post(apiURL, formData);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Failed to create candidate');
        return response.data;
      }
      if (candidates["id"] != null) {
        toaster.success(response.message?.toString().capitalizeFirst ?? 'Candidate update successfully');
      } else {
        toaster.success(response.message?.toString().capitalizeFirst ?? 'Candidate created successfully');
      }
    } catch (err) {
      toaster.error(err.toString());
    }
    return [];
  }

  Future<Map<String, dynamic>> listVendorCandidates(Map<String, dynamic> body) async {
    try {
      final response = await _apiManager.post(APIIndex.listVendorCandidates, body);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Something went wrong');
        return {};
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return {};
    }
  }

  Future<Map<String, dynamic>> removeCandidate(Map<String, dynamic> body) async {
    try {
      final response = await _apiManager.post(APIIndex.removeCandidate, body);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Something went wrong');
        return {};
      }
      toaster.success(response.message ?? 'Candidates deleted successfully');
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return {};
    }
  }

  Future<Map<String, dynamic>> changeStatusOfCandidateAvailability(Map<String, dynamic> body) async {
    try {
      final response = await _apiManager.post(APIIndex.changeStatusOfCandidateAvailability, body);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Something went wrong');
        return {};
      }
      toaster.success(response.message ?? 'Candidates Availability ${body["status"]}');
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return {};
    }
  }

  Future<void> logout() async {
    await clearStorage();
    Get.offAllNamed(AppRouteNames.login);
  }
}
