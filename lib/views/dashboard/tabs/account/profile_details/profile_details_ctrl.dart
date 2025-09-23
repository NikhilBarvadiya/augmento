import 'package:augmento/utils/config/session.dart';
import 'package:augmento/utils/storage.dart';
import 'package:get/get.dart';

class ProfileDetailsCtrl extends GetxController {
  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});
  final RxBool isExpanded = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    final user = read(AppSession.userData) ?? {};
    userData.value = user;
  }

  void toggleExpansion() {
    isExpanded.toggle();
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
