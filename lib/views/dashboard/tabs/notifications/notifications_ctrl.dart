import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:get/get.dart';

class NotificationsCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  var notifications = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs, hasMore = true.obs;
  var page = 1.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    debounce(searchQuery, (_) => fetchNotifications(reset: true), time: const Duration(milliseconds: 500));
  }

  Future<void> fetchNotifications({bool reset = false}) async {
    if (reset) {
      page.value = 1;
      notifications.clear();
      hasMore.value = true;
    }
    if (!hasMore.value || isLoading.value) return;
    isLoading.value = true;
    try {
      final response = await _authService.getNotifications({'limit': 10, 'page': page.value, 'search': searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim()});
      if (response.isNotEmpty) {
        final newNotifications = List<Map<String, dynamic>>.from(response['notifications'] ?? []);
        notifications.addAll(newNotifications);
        hasMore.value = response['total'] > notifications.length;
        if (hasMore.value) {
          page.value += 1;
        }
      }
    } catch (e) {
      toaster.error('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}
