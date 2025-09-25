import 'package:augmento/utils/config/session.dart';
import 'package:augmento/utils/storage.dart';
import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_management_ctrl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class JobDetailsCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  var candidates = <Map<String, dynamic>>[].obs;
  var selectedCandidates = <String>[].obs;
  var isLoading = false.obs, hasMore = true.obs;
  var image = Rx<PlatformFile?>(null);
  var page = 1.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCandidates();
    debounce(searchQuery, (_) => fetchCandidates(reset: true), time: const Duration(milliseconds: 500));
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
        'status': "Available",
        'availability': null,
        'isProfilCompleted': true,
      });
      if (response.isNotEmpty) {
        final newCandidates = List<Map<String, dynamic>>.from(response['docs'] ?? []);
        candidates.addAll(newCandidates);
        hasMore.value = response['hasNextPage'] == true;
        if (hasMore.value) {
          page.value = response['nextPage'] ?? (page.value + 1);
        }
      }
    } catch (e) {
      toaster.error('Error fetching candidates: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickFile(String type) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf']);
    if (result != null) {
      image.value = result.files.first;
    }
  }

  Future<void> startOnboarding({
    required String? candidateId,
    required String? jobApplicationId,
    required String? jobId,
    required String employeeName,
    required String firstName,
    required String lastName,
    required String nonTmobileEmail,
    required String workerMobileContactNumber,
    required String documentType,
    required String documentNumber,
    required String birthdate,
    required String physicalLocation,
    required String homeCity,
    required String homeState,
    required String homeZipCode,
  }) async {
    try {
      isLoading.value = true;
      Map<String, dynamic> json = {
        'candidateId': candidateId,
        'jobApplicationId': jobApplicationId,
        'jobId': jobId,
        'employeeName': employeeName,
        'firstName': firstName,
        'lastName': lastName,
        'nonTmobileEmail': nonTmobileEmail,
        'workerMobileContactNumber': workerMobileContactNumber,
        'birthdate': birthdate,
        'physicalLocation': physicalLocation,
        'homeCity': homeCity,
        'homeState': homeState,
        'homeZipCode': homeZipCode,
        'documentType': documentType,
        'documentNumber': documentNumber,
      };
      final response = await _authService.submitOnboardingDetails(json, image.value);
      if (response.isNotEmpty) {
        final jobsCtrl = Get.find<JobsCtrl>();
        jobsCtrl.onTabChanged(4);
      }
    } catch (e) {
      toaster.error('Error An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyForJob(String jobId) async {
    try {
      final user = read(AppSession.userData) ?? {};
      final vendorId = user["_id"];
      if (vendorId == null) {
        toaster.error('Vendor ID not found. Please log in again.');
        return;
      }
      final response = await _authService.applyForJob({'jobId': jobId, 'candidates': selectedCandidates.toList(), 'vendorId': vendorId});
      if (response.isNotEmpty) {
        final jobsCtrl = Get.find<JobsCtrl>();
        jobsCtrl.onTabChanged(1);
      }
    } catch (e) {
      toaster.error('Error applying for job: $e');
    }
  }
}
