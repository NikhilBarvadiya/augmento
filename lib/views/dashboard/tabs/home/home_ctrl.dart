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

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () async => await onRefresh());
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
    await fetchDashboardData();
    await fetchRecentProjects();
    await interviewTimeline();
  }
}
