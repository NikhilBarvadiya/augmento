import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:get/get.dart';

class HomeCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  var isLoading = true.obs;
  var counts = {}.obs;
  var activeJobs = <Map<String, dynamic>>[].obs, jobApplications = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
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
}
