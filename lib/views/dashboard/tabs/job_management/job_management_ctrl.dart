import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:get/get.dart';

class JobsCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  var availableJobs = <Map<String, dynamic>>[].obs, appliedJobs = <Map<String, dynamic>>[].obs;
  var selectedJobs = <Map<String, dynamic>>[].obs, rejectedJobs = <Map<String, dynamic>>[].obs;
  var onboardJobs = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var hasMore = <String, bool>{}.obs, pages = <String, int>{}.obs;
  var filters = <String, dynamic>{}.obs, counts = <String, dynamic>{}.obs;
  var searchQuery = ''.obs, statusFilter = ''.obs;

  int initialTab = 0;
  final Map<String, dynamic>? initialFilter;

  JobsCtrl({this.initialTab = 0, this.initialFilter});

  @override
  void onInit() {
    super.onInit();
    _initializePagesAndMore();
    if (initialFilter != null) {
      filters.value = initialFilter!;
    }
    _fetchInitialTabData();
    debounce(searchQuery, (_) => onTabChanged(initialTab), time: const Duration(milliseconds: 500));
    debounce(statusFilter, (_) => onTabChanged(initialTab), time: const Duration(milliseconds: 500));
    fetchCounts();
  }

  void _initializePagesAndMore() {
    for (var type in ['available', 'applied', 'selected', 'rejected', 'onboard']) {
      pages[type] = 1;
      hasMore[type] = true;
    }
  }

  void _fetchInitialTabData() {
    switch (initialTab) {
      case 0:
        fetchAvailableJobs(reset: true);
        break;
      case 1:
        fetchStatusWiseJobs(reset: true, status: initialFilter?['status'] is List ? initialFilter!['status'] : ['Pending']);
        break;
      case 2:
        fetchStatusWiseJobs(reset: true, status: initialFilter?['status'] is List ? initialFilter!['status'] : ['Selected']);
        break;
      case 3:
        fetchStatusWiseJobs(reset: true, status: initialFilter?['status'] is List ? initialFilter!['status'] : ['Rejected']);
        break;
      case 4:
        fetchOnboardJobs(reset: true, status: initialFilter?['status'] is List ? initialFilter!['status'] : ['Accepted', 'Rejected', 'Pending']);
        break;
    }
  }

  void onTabChanged(int index) {
    initialTab = index;
    searchQuery.value = "";
    update();
    switch (index) {
      case 0:
        fetchAvailableJobs(reset: true);
        break;
      case 1:
        fetchStatusWiseJobs(reset: true, status: ['Pending']);
        break;
      case 2:
        fetchStatusWiseJobs(reset: true, status: ['Selected']);
        break;
      case 3:
        fetchStatusWiseJobs(reset: true, status: ['Rejected']);
        break;
      case 4:
        fetchOnboardJobs(reset: true, status: statusFilter.value);
        break;
    }
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    try {
      final response = await _authService.getJobAndJobApplicationCounts(filters);
      if (response.isNotEmpty) {
        counts.value = response;
      }
    } catch (e) {
      toaster.error('Error fetching counts: $e');
    }
  }

  Future<void> fetchAvailableJobs({bool reset = false}) async {
    await _fetchJobs('available', _authService.listPublishedJobs, reset: reset);
  }

  Future<void> fetchStatusWiseJobs({bool reset = false, required List<String> status}) async {
    String type = status.contains('Pending') ? 'applied' : status.first.toLowerCase();
    await _fetchJobs(type, _authService.listStatusWiseCandidateJobs, reset: reset, extraParams: {'status': status});
  }

  Future<void> fetchOnboardJobs({bool reset = false, String status = ""}) async {
    await _fetchJobs('onboard', _authService.listOnboardedCandidates, reset: reset, extraParams: {'status': status});
  }

  Future<void> _fetchJobs(String type, Function apiFunction, {bool reset = false, Map<String, dynamic>? extraParams}) async {
    if (reset) {
      pages[type] = 1;
      _getListByType(type).clear();
      hasMore[type] = true;
    }
    if (!hasMore[type]! || isLoading.value) return;
    isLoading.value = true;
    try {
      final body = {'page': pages[type], 'search': searchQuery.value, 'limit': 10, ...filters, if (extraParams != null) ...extraParams};
      final response = await apiFunction(body);
      if (response.isNotEmpty) {
        final newJobs = List<Map<String, dynamic>>.from(response['docs'] ?? []);
        _getListByType(type).addAll(newJobs);
        hasMore[type] = response['hasNextPage'] == true;
        if (hasMore[type]!) {
          pages[type] = response['nextPage'] ?? (pages[type]! + 1);
        }
      }
    } catch (e) {
      toaster.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  RxList<Map<String, dynamic>> _getListByType(String type) {
    switch (type) {
      case 'available':
        return availableJobs;
      case 'applied':
        return appliedJobs;
      case 'selected':
        return selectedJobs;
      case 'rejected':
        return rejectedJobs;
      case 'onboard':
        return onboardJobs;
      default:
        return <Map<String, dynamic>>[].obs;
    }
  }

  void applyFilters(Map<String, dynamic> newFilters) {
    filters.value = newFilters;
    fetchAvailableJobs(reset: true);
    fetchCounts();
  }

  Future<void> applyForJob(String jobId) async {
    await _authService.applyForJob({"jobId": jobId});
  }
}
