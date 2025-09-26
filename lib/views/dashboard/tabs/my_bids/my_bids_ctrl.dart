import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class MyBidsCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var bids = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs, hasMore = true.obs;
  var page = 1.obs;
  var searchQuery = ''.obs, statusFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyBids();
    debounce(searchQuery, (_) => fetchMyBids(reset: true), time: const Duration(milliseconds: 500));
    debounce(statusFilter, (_) => fetchMyBids(reset: true), time: const Duration(milliseconds: 300));
  }

  Future<void> fetchMyBids({bool reset = false}) async {
    if (reset) {
      page.value = 1;
      bids.clear();
      hasMore.value = true;
    }
    if (!hasMore.value || isLoading.value) return;
    isLoading.value = true;
    try {
      final response = await _authService.listMyBids({
        'limit': 10,
        'page': page.value,
        'projectId': null,
        'search': searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
        'status': statusFilter.value == 'all' ? null : statusFilter.value,
      });
      if (response.isNotEmpty) {
        final newBids = List<Map<String, dynamic>>.from(response['docs'] ?? []);
        bids.addAll(newBids);
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

  void changeStatusFilter(String status) {
    statusFilter.value = status;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'accepted':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }

  String getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '⏳';
      case 'accepted':
        return '✅';
      case 'rejected':
        return '❌';
      default:
        return '📄';
    }
  }

  int getBidCountByStatus(String status) {
    if (status == 'all') return bids.length;
    return bids.where((bid) => bid['status'] == status).length;
  }
}
