import 'package:augmento/utils/config/session.dart';
import 'package:augmento/utils/storage.dart';
import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:get/get.dart';

class HomeCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  var isLoading = true.obs;
  var counts = {}.obs;
  var activeJobs = <Map<String, dynamic>>[].obs, jobApplications = <Map<String, dynamic>>[].obs;
  var recentProjects = <Map<String, dynamic>>[].obs, interviews = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () async => await onRefresh());
  }

  Future<void> loadUserData() async {
    final user = await read(AppSession.userData) ?? {};
    userData.value = user;
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      final response = await _authService.getDashboardData();
      if (response.isNotEmpty) {
        counts.value = response['counts'] ?? {};
        activeJobs.assignAll(List<Map<String, dynamic>>.from(response['activeJobs'] ?? []));
        jobApplications.assignAll(List<Map<String, dynamic>>.from(response['jobApplication'] ?? []));
      }
    } catch (e) {
      toaster.error("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> interviewTimeline() async {
    isLoading.value = true;
    try {
      final response = await _authService.interviewTimeline();
      if (response.isNotEmpty) {
        interviews.value = List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      toaster.error("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRecentProjects() async {
    final user = read(AppSession.userData) ?? {};
    final vendorId = user["_id"];
    if (vendorId == null) {
      toaster.error('Vendor ID not found. Please log in again.');
      return;
    }
    isLoading.value = true;
    try {
      final response = await _authService.listProjects({'page': 1, 'limit': 5, 'vendorId': vendorId});
      if (response.isNotEmpty) {
        recentProjects.value = List<Map<String, dynamic>>.from(response['docs'] ?? []);
      }
    } catch (e) {
      toaster.error('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    await loadUserData();
    await fetchDashboardData();
    await fetchRecentProjects();
    await interviewTimeline();
  }

  double getCompletionPercentage() {
    final user = userData.value;
    int filledFields = 0, totalFields = 15;
    if (user['name']?.isNotEmpty == true) filledFields++;
    if (user['company']?.isNotEmpty == true) filledFields++;
    if (user['email']?.isNotEmpty == true) filledFields++;
    if (user['mobile']?.isNotEmpty == true) filledFields++;
    if (user['designation']?.isNotEmpty == true) filledFields++;
    if (user['address']?.isNotEmpty == true) filledFields++;
    if (user['website']?.isNotEmpty == true) filledFields++;
    if (user['gstNumber']?.isNotEmpty == true) filledFields++;
    if (user['engagementModels']?.isNotEmpty == true) filledFields++;
    if (user['timeZones']?.isNotEmpty == true) filledFields++;
    if (user['bankName']?.isNotEmpty == true) filledFields++;
    if (user['bankAccountNumber']?.isNotEmpty == true) filledFields++;
    if (user['ifscCode']?.isNotEmpty == true) filledFields++;
    if (user['bankAccountHolderName']?.isNotEmpty == true) filledFields++;
    if (user['bankBranchName']?.isNotEmpty == true) filledFields++;
    return (filledFields / totalFields);
  }
}
