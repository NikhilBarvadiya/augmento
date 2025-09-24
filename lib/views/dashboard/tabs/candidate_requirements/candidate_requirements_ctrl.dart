import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CandidateRequirementsCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var requirements = <Map<String, dynamic>>[].obs;
  var stats = <String, dynamic>{}.obs;
  var isLoading = false.obs, hasMore = true.obs;
  var page = 1.obs;
  var searchQuery = ''.obs, statusFilter = ''.obs, status = 'Draft'.obs;

  final jobTitleCtrl = TextEditingController();
  final jobTypeCtrl = TextEditingController();
  final experienceLevelCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final responsibilityCtrl = TextEditingController();
  final summaryCtrl = TextEditingController();
  final salaryMinCtrl = TextEditingController();
  final salaryMaxCtrl = TextEditingController();
  final salaryCurrencyCtrl = TextEditingController();

  final requiredSkillsCtrl = TextEditingController();
  final preferredSkillsCtrl = TextEditingController();
  final certificationCtrl = TextEditingController();
  final educationQualificationCtrl = TextEditingController();
  final softSkillsCtrl = TextEditingController();
  final techStackCtrl = TextEditingController();

  final RxList<String> requiredSkillsList = <String>[].obs;
  final RxList<String> preferredSkillsList = <String>[].obs;
  final RxList<String> certificationList = <String>[].obs;
  final RxList<String> educationQualificationList = <String>[].obs;
  final RxList<String> softSkillsList = <String>[].obs;
  final RxList<String> techStackList = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequirements();
    fetchStats();
    debounce(searchQuery, (_) => fetchRequirements(reset: true), time: const Duration(milliseconds: 500));
    debounce(statusFilter, (_) => fetchRequirements(reset: true), time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    jobTitleCtrl.dispose();
    jobTypeCtrl.dispose();
    experienceLevelCtrl.dispose();
    locationCtrl.dispose();
    responsibilityCtrl.dispose();
    summaryCtrl.dispose();
    salaryMinCtrl.dispose();
    salaryMaxCtrl.dispose();
    salaryCurrencyCtrl.dispose();
    requiredSkillsCtrl.dispose();
    preferredSkillsCtrl.dispose();
    certificationCtrl.dispose();
    educationQualificationCtrl.dispose();
    softSkillsCtrl.dispose();
    techStackCtrl.dispose();
  }

  Future<void> fetchRequirements({bool reset = false}) async {
    if (reset) {
      page.value = 1;
      requirements.clear();
      hasMore.value = true;
    }
    if (!hasMore.value || isLoading.value) return;
    isLoading.value = true;
    try {
      final response = await _authService.listCandidateRequirements({
        'page': page.value,
        'limit': 10,
        'search': searchQuery.value.trim(),
        if (statusFilter.value.isNotEmpty) 'status': statusFilter.value,
      });
      if (response.isNotEmpty) {
        final newRequirements = List<Map<String, dynamic>>.from(response['docs'] ?? []);
        requirements.addAll(newRequirements);
        hasMore.value = response["hasNextPage"] == true;
        if (hasMore.value) {
          page.value = (response["nextPage"] ?? page.value + 1);
        }
      }
    } catch (e) {
      toaster.error('Error fetching requirements: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStats() async {
    try {
      stats.value = await _authService.getRequirementStats();
    } catch (e) {
      toaster.error('Error fetching stats: ${e.toString()}');
    }
  }

  Future<void> createRequirement({String? candidateId}) async {
    if (!_validateForm()) return;
    isLoading.value = true;
    try {
      final requirementData = _buildRequirementData();
      if (candidateId != null && candidateId.isNotEmpty) {
        requirementData["_id"] = candidateId;
      }
      final response = await _authService.createCandidateRequirement(requirementData);
      if (response.isNotEmpty) {
        _handleSuccessfulCreation(response, candidateId);
      }
    } catch (e) {
      toaster.error('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _buildRequirementData() {
    return {
      'jobTitle': jobTitleCtrl.text.trim(),
      'jobType': jobTypeCtrl.text.trim(),
      'experienceLevel': experienceLevelCtrl.text.trim(),
      'location': locationCtrl.text.trim(),
      'requiredSkills': requiredSkillsList.toList(),
      'preferredSkills': preferredSkillsList.toList(),
      'certification': certificationList.toList(),
      'educationQualification': educationQualificationList.toList(),
      'responsibility': responsibilityCtrl.text.trim(),
      'summary': summaryCtrl.text.trim(),
      'salaryRange': {'min': double.tryParse(salaryMinCtrl.text.trim()) ?? 0.0, 'max': double.tryParse(salaryMaxCtrl.text.trim()) ?? 0.0, 'currency': salaryCurrencyCtrl.text.trim()},
      'softSkills': softSkillsList.toList(),
      'techStack': techStackList.toList(),
      'status': status.value,
    };
  }

  void _handleSuccessfulCreation(Map<String, dynamic> response, String? candidateId) {
    clearForm();
    fetchStats();
    if (candidateId != null && candidateId.isNotEmpty) {
      int index = requirements.indexWhere((e) => e["_id"] == candidateId);
      if (index != -1) {
        requirements[index] = response;
      }
      toaster.success('Requirement updated successfully');
    } else {
      requirements.insert(0, Map<String, dynamic>.from(response));
      toaster.success('Requirement created successfully');
    }
    Get.back();
  }

  Future<void> deleteRequirement(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Requirement'),
        content: const Text('Are you sure you want to delete this job requirement? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    isLoading.value = true;
    try {
      final response = await _authService.deleteCandidateRequirement({'id': id});
      if (response == true) {
        requirements.removeWhere((e) => e["_id"] == id);
        fetchStats();
        toaster.success('Requirement deleted successfully');
      }
    } catch (e) {
      toaster.error('Error deleting requirement: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (jobTitleCtrl.text.trim().length < 3) {
      toaster.warning('Job title must be at least 3 characters long');
      return false;
    }
    if (!['Full-time', 'Part-time', 'Contract', 'Internship'].contains(jobTypeCtrl.text.trim())) {
      toaster.warning('Please select a valid job type');
      return false;
    }
    if (!['Entry', 'Mid', 'Senior', 'Lead'].contains(experienceLevelCtrl.text.trim())) {
      toaster.warning('Please select a valid experience level');
      return false;
    }
    if (locationCtrl.text.trim().length < 2) {
      toaster.warning('Location must be at least 2 characters long');
      return false;
    }
    if (requiredSkillsList.isEmpty) {
      toaster.warning('At least one required skill must be specified');
      return false;
    }
    if (educationQualificationList.isEmpty) {
      toaster.warning('At least one education qualification must be specified');
      return false;
    }
    if (responsibilityCtrl.text.trim().length < 10) {
      toaster.warning('Responsibilities must be at least 10 characters long');
      return false;
    }
    if (summaryCtrl.text.trim().length < 10) {
      toaster.warning('Summary must be at least 10 characters long');
      return false;
    }
    final minSalary = double.tryParse(salaryMinCtrl.text.trim()) ?? 0.0;
    final maxSalary = double.tryParse(salaryMaxCtrl.text.trim()) ?? 0.0;
    if (minSalary <= 0 || maxSalary <= 0) {
      toaster.warning('Please enter valid salary amounts');
      return false;
    }
    if (minSalary >= maxSalary) {
      toaster.warning('Maximum salary must be greater than minimum salary');
      return false;
    }
    if (!['USD', 'EUR', 'GBP', 'INR'].contains(salaryCurrencyCtrl.text.trim())) {
      toaster.warning('Please select a valid currency');
      return false;
    }
    if (softSkillsList.isEmpty) {
      toaster.warning('At least one soft skill must be specified');
      return false;
    }
    if (!['Active', 'Inactive', 'Draft'].contains(status.value)) {
      toaster.warning('Please select a valid status');
      return false;
    }
    return true;
  }

  void clearForm() {
    jobTitleCtrl.clear();
    jobTypeCtrl.clear();
    experienceLevelCtrl.clear();
    locationCtrl.clear();
    responsibilityCtrl.clear();
    summaryCtrl.clear();
    salaryMinCtrl.clear();
    salaryMaxCtrl.clear();
    salaryCurrencyCtrl.clear();
    requiredSkillsCtrl.clear();
    preferredSkillsCtrl.clear();
    certificationCtrl.clear();
    educationQualificationCtrl.clear();
    softSkillsCtrl.clear();
    techStackCtrl.clear();
    requiredSkillsList.clear();
    preferredSkillsList.clear();
    certificationList.clear();
    educationQualificationList.clear();
    softSkillsList.clear();
    techStackList.clear();
    status.value = 'Draft';
  }

  void addToRequiredSkills(String skill) {
    if (skill.trim().isNotEmpty && !requiredSkillsList.contains(skill.trim())) {
      requiredSkillsList.add(skill.trim());
    }
  }

  void addToPreferredSkills(String skill) {
    if (skill.trim().isNotEmpty && !preferredSkillsList.contains(skill.trim())) {
      preferredSkillsList.add(skill.trim());
    }
  }

  void addToCertifications(String certification) {
    if (certification.trim().isNotEmpty && !certificationList.contains(certification.trim())) {
      certificationList.add(certification.trim());
    }
  }

  void addToEducationQualifications(String education) {
    if (education.trim().isNotEmpty && !educationQualificationList.contains(education.trim())) {
      educationQualificationList.add(education.trim());
    }
  }

  void addToSoftSkills(String skill) {
    if (skill.trim().isNotEmpty && !softSkillsList.contains(skill.trim())) {
      softSkillsList.add(skill.trim());
    }
  }

  void addToTechStack(String tech) {
    if (tech.trim().isNotEmpty && !techStackList.contains(tech.trim())) {
      techStackList.add(tech.trim());
    }
  }

  void populateForm(Map<String, dynamic> requirement) {
    clearForm();
    jobTitleCtrl.text = '${requirement['jobTitle'] ?? ''} (Copy)';
    jobTypeCtrl.text = requirement['jobType'] ?? '';
    experienceLevelCtrl.text = requirement['experienceLevel'] ?? '';
    locationCtrl.text = requirement['location'] ?? '';
    responsibilityCtrl.text = requirement['responsibility'] ?? '';
    summaryCtrl.text = requirement['summary'] ?? '';
    salaryMinCtrl.text = requirement['salaryRange']?['min']?.toString() ?? '';
    salaryMaxCtrl.text = requirement['salaryRange']?['max']?.toString() ?? '';
    salaryCurrencyCtrl.text = requirement['salaryRange']?['currency'] ?? '';
    status.value = 'Draft';
    if (requirement['requiredSkills'] != null) {
      requiredSkillsList.value = List<String>.from(requirement['requiredSkills']);
    }
    if (requirement['preferredSkills'] != null) {
      preferredSkillsList.value = List<String>.from(requirement['preferredSkills']);
    }
    if (requirement['certification'] != null) {
      certificationList.value = List<String>.from(requirement['certification']);
    }
    if (requirement['educationQualification'] != null) {
      educationQualificationList.value = List<String>.from(requirement['educationQualification']);
    }
    if (requirement['softSkills'] != null) {
      softSkillsList.value = List<String>.from(requirement['softSkills']);
    }
    if (requirement['techStack'] != null) {
      techStackList.value = List<String>.from(requirement['techStack']);
    }
  }
}
