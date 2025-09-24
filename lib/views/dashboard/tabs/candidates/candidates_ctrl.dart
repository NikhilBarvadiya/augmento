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
  var page = 1.obs, totalDocs = 0.obs;
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
  var profileImage = Rx<PlatformFile?>(null), resume = Rx<PlatformFile?>(null), aadhaarCard = Rx<PlatformFile?>(null);
  var panCard = Rx<PlatformFile?>(null);
  var candidateStatus = 'Available'.obs, pdfFormat = 'Format1'.obs;
  var extractedResumeData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCandidates();
    debounce(searchQuery, (_) => fetchCandidates(reset: true), time: const Duration(milliseconds: 500));
    debounce(statusFilter, (_) => fetchCandidates(reset: true), time: const Duration(milliseconds: 500));
    debounce(availabilityFilter, (_) => fetchCandidates(reset: true), time: const Duration(milliseconds: 500));
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
        candidates.addAll(List<Map<String, dynamic>>.from(response['docs'] ?? []));
        totalDocs.value = response['totalDocs'] ?? 0;
        hasMore.value = response['hasNextPage'] ?? false;
        page.value++;
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
      final candidateData = {
        'name': nameCtrl.text.trim(),
        'mobile': mobileCtrl.text.trim(),
        'skills': jsonEncode(skillsCtrl.text.trim().split(',').map((s) => s.trim()).toList()),
        'techStack': jsonEncode(techStackCtrl.text.trim().split(',').map((s) => s.trim()).toList()),
        'education': jsonEncode(educationCtrl.text.trim().split(',').map((s) => s.trim()).toList()),
        'experience': double.tryParse(experienceCtrl.text.trim()) ?? 0.0,
        'availability': availabilityCtrl.text.trim(), // ["Immediate", "1 Week", "2 Weeks", "1 Month", "Other"],
        'itfuturzCandidate': isCandidate.value,
        'status': candidateStatus.value,
        'charges': double.tryParse(chargesCtrl.text.trim()) ?? 0.0,
        'currentSalary': double.tryParse(currentSalaryCtrl.text.trim()) ?? 0.0,
      };
      if (candidateId != null && candidateId.isNotEmpty) {
        candidateData["id"] = candidateId;
      }
      final response = await _authService.createCandidateProfile(candidateData, profileImage.value, resume.value);
      if (response.isNotEmpty) {
        clearForm();
        candidates.addAll(response);
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
      if (response.isNotEmpty) {
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
    skillsCtrl.clear();
    techStackCtrl.clear();
    educationCtrl.clear();
    experienceCtrl.clear();
    availabilityCtrl.clear();
    chargesCtrl.clear();
    currentSalaryCtrl.clear();
    profileImage.value = null;
    resume.value = null;
    aadhaarCard.value = null;
    panCard.value = null;
    isCandidate.value = false;
    candidateStatus.value = 'Available';
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
        case 'aadhaarCard':
          aadhaarCard.value = result.files.first;
          break;
        case 'panCard':
          panCard.value = result.files.first;
          break;
      }
    }
  }
}
