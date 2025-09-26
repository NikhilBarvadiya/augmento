import 'package:augmento/utils/config/session.dart';
import 'package:augmento/utils/storage.dart';
import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:get/get.dart';

class ProjectsCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  var projects = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs, hasMore = true.obs;
  var page = 1.obs;
  var searchQuery = ''.obs, experienceLevelFilter = ''.obs, scopeFilter = ''.obs, statusFilter = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
    debounce(searchQuery, (_) => fetchProjects(reset: true), time: const Duration(milliseconds: 500));
    debounce(experienceLevelFilter, (_) => fetchProjects(reset: true), time: const Duration(milliseconds: 500));
    debounce(scopeFilter, (_) => fetchProjects(reset: true), time: const Duration(milliseconds: 500));
    debounce(statusFilter, (_) => fetchProjects(reset: true), time: const Duration(milliseconds: 500));
  }

  Future<void> fetchProjects({bool reset = false}) async {
    if (reset) {
      page.value = 1;
      projects.clear();
      hasMore.value = true;
    }
    if (!hasMore.value || isLoading.value) return;
    final user = read(AppSession.userData) ?? {};
    final vendorId = user["_id"];
    if (vendorId == null) {
      toaster.error('Vendor ID not found. Please log in again.');
      return;
    }
    isLoading.value = true;
    try {
      final response = await _authService.listProjects({
        'budgetType': null,
        'experienceLevel': experienceLevelFilter.value.isNotEmpty ? experienceLevelFilter.value : null,
        'limit': 10,
        'page': page.value,
        'scope': scopeFilter.value.isNotEmpty ? scopeFilter.value : null,
        'search': searchQuery.value.trim(),
        'status': statusFilter.value.isNotEmpty ? statusFilter.value : null,
        'vendorId': vendorId,
      });
      if (response.isNotEmpty) {
        final newProjects = List<Map<String, dynamic>>.from(response['docs'] ?? []);
        projects.addAll(newProjects);
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
}
