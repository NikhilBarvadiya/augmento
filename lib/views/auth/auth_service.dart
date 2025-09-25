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

  Future<dynamic> createCandidateProfile(Map<String, dynamic> candidates, PlatformFile? profileImage, PlatformFile? resume) async {
    try {
      dio.FormData? formData;
      if (candidates["id"] != null) formData = dio.FormData.fromMap(candidates);
      if (candidates["id"] == null) {
        formData = dio.FormData.fromMap({
          "candidates": jsonEncode([candidates]),
        });
      }
      if (formData == null) return;
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
        return null;
      }
      if (candidates["id"] != null) {
        toaster.success(response.message?.toString().capitalizeFirst ?? 'Candidate update successfully');
      } else {
        toaster.success(response.message?.toString().capitalizeFirst ?? 'Candidate created successfully');
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
    }
    return null;
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

  Future<bool> changeStatusOfCandidateAvailability(Map<String, dynamic> body) async {
    try {
      final response = await _apiManager.post(APIIndex.changeStatusOfCandidateAvailability, body);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Something went wrong');
        return false;
      }
      toaster.success(response.message ?? 'Candidates Availability ${body["status"]}');
      return true;
    } catch (err) {
      toaster.error(err.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>> createCandidateRequirement(Map<String, dynamic> candidates) async {
    try {
      String apiURL = candidates["_id"] != null ? APIIndex.updateCandidateRequirement : APIIndex.createCandidateRequirement;
      final response = await _apiManager.post(apiURL, candidates);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Failed to create candidate');
        return {};
      }
      if (candidates["_id"] != null) {
        toaster.success(response.message?.toString().capitalizeFirst ?? 'Candidate update requirement successfully');
      } else {
        toaster.success(response.message?.toString().capitalizeFirst ?? 'Candidate created requirement successfully');
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return {};
    }
  }

  Future<Map<String, dynamic>> listCandidateRequirements(Map<String, dynamic> body) async {
    try {
      final response = await _apiManager.post(APIIndex.listCandidateRequirements, body);
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

  Future<Map<String, dynamic>> getRequirementStats() async {
    try {
      final response = await _apiManager.post(APIIndex.getRequirementStats, {});
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

  Future<bool> deleteCandidateRequirement(Map<String, dynamic> body) async {
    try {
      final response = await _apiManager.post(APIIndex.deleteCandidateRequirement, body);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Something went wrong');
        return false;
      }
      toaster.success(response.message ?? 'Candidates requirement deleted successfully');
      return true;
    } catch (err) {
      toaster.error(err.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>> createDigitalProduct(Map<String, dynamic> product) async {
    try {
      String apiURL = product["id"] != null ? APIIndex.updateProduct : APIIndex.createProduct;
      final response = await _apiManager.post(apiURL, product);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Failed to create candidate');
        return {};
      }
      if (product["id"] != null) {
        toaster.success(response.message?.toString().capitalizeFirst ?? 'Product updated successfully');
      } else {
        toaster.success(response.message?.toString().capitalizeFirst ?? 'Product created successfully');
      }
      return response.data;
    } catch (e) {
      throw Exception('Failed to create digital product: $e');
    }
  }

  Future<Map<String, dynamic>> digitalProducts(Map<String, dynamic> body) async {
    try {
      final response = await _apiManager.post(APIIndex.digitalProducts, body);
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

  Future<bool> deleteProduct(Map<String, dynamic> body) async {
    try {
      final response = await _apiManager.post(APIIndex.deleteProduct, body);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Something went wrong');
        return false;
      }
      toaster.success(response.message ?? 'Product deleted successfully');
      return true;
    } catch (err) {
      toaster.error(err.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>> listPublishedJobs(Map<String, dynamic> body) async {
    try {
      final response = await _apiManager.post(APIIndex.listPublishedJobs, body);
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

  Future<Map<String, dynamic>> listStatusWiseCandidateJobs(Map<String, dynamic> body) async {
    try {
      final response = await _apiManager.post(APIIndex.listStatusWiseCandidateJobs, body);
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

  Future<Map<String, dynamic>> listOnboardedCandidates(Map<String, dynamic> body) async {
    try {
      final response = await _apiManager.post(APIIndex.listOnboardedCandidates, body);
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

  Future<Map<String, dynamic>> getJobAndJobApplicationCounts(Map<String, dynamic> body) async {
    try {
      final response = await _apiManager.post(APIIndex.getJobAndJobApplicationCounts, body);
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

  Future<Map<String, dynamic>> applyForJob(Map<String, dynamic> body) async {
    try {
      final response = await _apiManager.post(APIIndex.applyForJob, body);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Something went wrong');
        return {};
      }
      toaster.success('Applied successfully');
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return {};
    }
  }

  Future<Map<String, dynamic>> submitOnboardingDetails(Map<String, dynamic> body, PlatformFile? image) async {
    try {
      dio.FormData? formData = dio.FormData.fromMap(body);
      if (image != null) {
        formData.files.add(MapEntry('document', await dio.MultipartFile.fromFile(image.path!, filename: image.name)));
      }
      final response = await _apiManager.post(APIIndex.submitOnboardingDetails, formData);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Something went wrong');
        return {};
      }
      toaster.success('Applied successfully');
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
