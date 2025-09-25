import 'package:augmento/views/dashboard/tabs/job_management/job_management_ctrl.dart';
import 'package:get/get.dart';

class JobFilterCtrl extends GetxController {
  final JobsCtrl jobsCtrl = Get.find<JobsCtrl>();
  var searchQuery = ''.obs;
  var selectedDatePosted = <String>[].obs;
  var selectedSkills = <String>[].obs;
  var selectedWorkTypes = <String>[].obs;
  var selectedShifts = <String>[].obs;
  var selectedJobTypes = <String>[].obs;
  var selectedExperienceLevels = <String>[].obs;
  var selectedStatuses = <String>[].obs;
  var salaryMin = Rx<int?>(null);
  var salaryMax = Rx<int?>(null);

  @override
  void onInit() {
    super.onInit();
    final currentFilters = jobsCtrl.filters;
    searchQuery.value = currentFilters['search'] ?? '';
    selectedDatePosted.value = currentFilters['datePosted'] != null ? [currentFilters['datePosted']] : [];
    selectedSkills.value = List<String>.from(currentFilters['skills'] ?? []);
    selectedWorkTypes.value = List<String>.from(currentFilters['WorkTypes'] ?? []);
    selectedShifts.value = List<String>.from(currentFilters['shift'] ?? []);
    selectedJobTypes.value = List<String>.from(currentFilters['jobType'] ?? []);
    selectedExperienceLevels.value = List<String>.from(currentFilters['experienceLevel'] ?? []);
    selectedStatuses.value = currentFilters['status'] != null ? [currentFilters['status']] : [];
    salaryMin.value = currentFilters['salaryMin'];
    salaryMax.value = currentFilters['salaryMax'];
  }

  void applyFilters() {
    final filters = <String, dynamic>{
      '_id': null,
      'datePosted': selectedDatePosted.isNotEmpty ? _mapDatePosted(selectedDatePosted.first) : null,
      'experienceLevel': selectedExperienceLevels.isNotEmpty ? selectedExperienceLevels.toList() : null,
      'jobType': selectedJobTypes.isNotEmpty ? selectedJobTypes.toList() : null,
      'salaryMin': salaryMin.value,
      'salaryMax': salaryMax.value,
      'search': searchQuery.value.isNotEmpty ? searchQuery.value : null,
      'shift': selectedShifts.isNotEmpty ? selectedShifts.toList() : null,
      'skills': selectedSkills.isNotEmpty ? selectedSkills.toList() : null,
      'status': selectedStatuses.isNotEmpty ? selectedStatuses.first : null,
      'WorkTypes': selectedWorkTypes.isNotEmpty ? selectedWorkTypes.toList() : null,
    };
    jobsCtrl.applyFilters(filters);
  }

  String _mapDatePosted(String displayValue) {
    switch (displayValue) {
      case 'Past 24 hours':
        return '24hours';
      case 'Past Week':
        return 'week';
      case 'Past Month':
        return 'month';
      case 'All Time':
        return '';
      default:
        return 'All';
    }
  }
}
