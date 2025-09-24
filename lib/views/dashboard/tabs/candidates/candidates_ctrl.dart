import 'dart:convert';
import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CandidatesCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  var candidates = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs, hasMore = true.obs, isProfileCompletedFilter = true.obs, isCandidate = false.obs;
  var page = 1.obs;
  var searchQuery = ''.obs, statusFilter = ''.obs, availabilityFilter = ''.obs;
  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final skillsCtrl = TextEditingController();
  final techStackCtrl = TextEditingController();
  final educationCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();
  final availabilityCtrl = TextEditingController();
  final chargesCtrl = TextEditingController();
  final currentSalaryCtrl = TextEditingController();
  var profileImage = Rx<PlatformFile?>(null), resume = Rx<PlatformFile?>(null);
  var candidateStatus = 'Available'.obs, pdfFormat = 'Format1'.obs;
  var extractedResumeData = {}.obs;

  final RxList<String> skillsList = <String>[].obs, techStackList = <String>[].obs, educationList = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCandidates();
    debounce(searchQuery, (_) => fetchCandidates(reset: true), time: const Duration(milliseconds: 500));
    debounce(statusFilter, (_) => fetchCandidates(reset: true), time: const Duration(milliseconds: 500));
    debounce(availabilityFilter, (_) => fetchCandidates(reset: true), time: const Duration(milliseconds: 500));
    debounce(isProfileCompletedFilter, (_) => fetchCandidates(reset: true), time: const Duration(milliseconds: 500));
  }

  Future<void> fetchCandidates({bool reset = false}) async {
    if (reset) {
      page.value = 1;
      candidates.clear();
      hasMore.value = true;
    }
    if (!hasMore.value || isLoading.value) return;
    isLoading.value = true;
    try {
      final response = await _authService.listVendorCandidates({
        'page': page.value,
        'limit': 10,
        'search': searchQuery.value.trim(),
        'status': statusFilter.value.isNotEmpty ? statusFilter.value : null,
        'availability': availabilityFilter.value.isNotEmpty ? availabilityFilter.value : null,
        'isProfilCompleted': isProfileCompletedFilter.value,
      });
      if (response.isNotEmpty) {
        final newCandidates = List<Map<String, dynamic>>.from(response['docs'] ?? []);
        candidates.addAll(newCandidates);
        hasMore.value = response["hasNextPage"] == true;
        hasMore.value = response["hasNextPage"] == true;
        if (hasMore.value) {
          page.value = (response["nextPage"] ?? page.value + 1);
        }
      }
    } catch (e) {
      toaster.error('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCandidate({String? candidateId}) async {
    isLoading.value = true;
    try {
      Map<String, dynamic> candidateData = {
        'name': nameCtrl.text.trim(),
        'mobile': mobileCtrl.text.trim(),
        'skills': candidateId != null && candidateId.isNotEmpty ? jsonEncode(skillsList.toList()) : skillsList,
        'techStack': candidateId != null && candidateId.isNotEmpty ? jsonEncode(techStackList.toList()) : techStackList,
        'education': candidateId != null && candidateId.isNotEmpty ? jsonEncode(educationList.toList()) : educationList,
        'experience': double.tryParse(experienceCtrl.text.trim()) ?? 0.0,
        'availability': availabilityCtrl.text.trim(),
        'itfuturzCandidate': isCandidate.value,
        'status': candidateStatus.value,
        'charges': double.tryParse(chargesCtrl.text.trim()) ?? 0.0,
        'currentSalary': double.tryParse(currentSalaryCtrl.text.trim()) ?? 0.0,
      };
      if (candidateId != null && candidateId.isNotEmpty) {
        candidateData["id"] = candidateId;
      }
      final response = await _authService.createCandidateProfile(candidateData, profileImage.value, resume.value);
      if (response != null) {
        clearForm();
        if (candidateId != null && candidateId.isNotEmpty) {
          int index = candidates.indexWhere((e) => e["_id"] == candidateId);
          if (index != -1) {
            candidates[index] = response;
          }
        } else {
          isLoading.value = false;
          await fetchCandidates(reset: true);
        }
        Get.back();
      }
    } catch (e) {
      toaster.error('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCandidates(List<String> ids) async {
    isLoading.value = true;
    try {
      final response = await _authService.removeCandidate({'ids': ids});
      if (response.isNotEmpty) {
        candidates.removeWhere((e) => e["_id"] == ids.first);
      }
    } catch (e) {
      toaster.error('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeCandidateStatus(String id, String status) async {
    isLoading.value = true;
    try {
      final response = await _authService.changeStatusOfCandidateAvailability({'id': id, 'status': status});
      if (response == true) {
        int index = candidates.indexWhere((e) => e["_id"] == id);
        if (index != -1) {
          candidates[index]["status"] = status;
        }
      }
    } catch (e) {
      toaster.error('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    nameCtrl.clear();
    mobileCtrl.clear();
    experienceCtrl.clear();
    availabilityCtrl.clear();
    chargesCtrl.clear();
    currentSalaryCtrl.clear();
    skillsList.clear();
    techStackList.clear();
    educationList.clear();
    isCandidate.value = false;
    candidateStatus.value = 'Available';
    profileImage.value = null;
    resume.value = null;
  }

  Future<void> pickFile(String type) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf']);
    if (result != null) {
      switch (type) {
        case 'profileImage':
          profileImage.value = result.files.first;
          break;
        case 'resume':
          resume.value = result.files.first;
          break;
      }
    }
  }
}
