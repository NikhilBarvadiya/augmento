import 'dart:convert';
import 'package:augmento/utils/config/session.dart';
import 'package:augmento/utils/storage.dart';
import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileEditCtrl extends GetxController {
  final formKey = GlobalKey<FormState>();
  final companyCtrl = TextEditingController();
  final websiteCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final contactPersonCtrl = TextEditingController();
  final designationCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final resourceCountCtrl = TextEditingController();
  final commentsCtrl = TextEditingController();
  final bankAccountHolderNameCtrl = TextEditingController();
  final bankAccountNumberCtrl = TextEditingController();
  final ifscCodeCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final bankBranchNameCtrl = TextEditingController();
  final gstNumberCtrl = TextEditingController();

  var engagementModels = <String>[].obs, timeZones = <String>[].obs;
  var panCard = Rx<PlatformFile?>(null), avatar = Rx<PlatformFile?>(null);
  var certificates = <PlatformFile>[].obs;

  var isLoading = false.obs, shakeForm = false.obs, isValidatingGST = false.obs;
  var gstValidationStatus = Rx<String?>(null);
  var currentStep = 0.obs;
  var completionPercentage = 0.0.obs;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    calculateCompletion();
    gstNumberCtrl.addListener(_onGSTChanged);
    emailCtrl.addListener(calculateCompletion);
    mobileCtrl.addListener(calculateCompletion);
    companyCtrl.addListener(calculateCompletion);
  }

  void loadUserData() {
    final user = read(AppSession.userData) ?? {};
    companyCtrl.text = user['company']?.toString() ?? '';
    websiteCtrl.text = user['website']?.toString() ?? '';
    addressCtrl.text = user['address']?.toString() ?? '';
    contactPersonCtrl.text = user['contactPerson']?.toString() ?? '';
    designationCtrl.text = user['designation']?.toString() ?? '';
    emailCtrl.text = user['email']?.toString() ?? '';
    mobileCtrl.text = user['mobile']?.toString() ?? '';
    resourceCountCtrl.text = user['resourceCount']?.toString() ?? '';
    commentsCtrl.text = user['comments']?.toString() ?? '';
    gstNumberCtrl.text = user['gstNumber']?.toString() ?? '';
    Map<String, dynamic>? bankDetails = jsonDecode(user['bankDetails']) as Map<String, dynamic>? ?? {};
    bankAccountHolderNameCtrl.text = bankDetails['bankAccountHolderName']?.toString() ?? '';
    bankAccountNumberCtrl.text = bankDetails['bankAccountNumber']?.toString() ?? '';
    bankNameCtrl.text = bankDetails['bankName']?.toString() ?? '';
    bankBranchNameCtrl.text = bankDetails['bankBranchName']?.toString() ?? '';
    if (user['engagementModels'] is List) {
      engagementModels.addAll((user['engagementModels'] as List).cast<String>().where((item) => item.trim().isNotEmpty));
    } else if (user['engagementModels'] is String) {
      final models = (user['engagementModels'] as String).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      engagementModels.addAll(models);
    }
    if (user['timeZones'] is List) {
      timeZones.addAll((user['timeZones'] as List).cast<String>().where((item) => item.trim().isNotEmpty));
    } else if (user['timeZones'] is String) {
      final zones = (user['timeZones'] as String).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      timeZones.addAll(zones);
    }
  }

  void calculateCompletion() {
    int filledFields = 0, totalFields = 15;
    if (companyCtrl.text.isNotEmpty) filledFields++;
    if (contactPersonCtrl.text.isNotEmpty) filledFields++;
    if (designationCtrl.text.isNotEmpty) filledFields++;
    if (emailCtrl.text.isNotEmpty && GetUtils.isEmail(emailCtrl.text)) filledFields++;
    if (mobileCtrl.text.isNotEmpty && GetUtils.isPhoneNumber(mobileCtrl.text)) filledFields++;
    if (websiteCtrl.text.isNotEmpty) filledFields++;
    if (addressCtrl.text.isNotEmpty) filledFields++;
    if (gstNumberCtrl.text.isNotEmpty && gstValidationStatus.value == 'valid') filledFields++;
    if (engagementModels.isNotEmpty) filledFields++;
    if (timeZones.isNotEmpty) filledFields++;
    if (resourceCountCtrl.text.isNotEmpty) filledFields++;
    if (bankAccountHolderNameCtrl.text.isNotEmpty) filledFields++;
    if (bankAccountNumberCtrl.text.isNotEmpty) filledFields++;
    if (bankNameCtrl.text.isNotEmpty) filledFields++;
    if (ifscCodeCtrl.text.isNotEmpty) filledFields++;
    completionPercentage.value = (filledFields / totalFields);
  }

  void _onGSTChanged() {
    if (gstNumberCtrl.text.length == 15) {
      validateGSTNumber();
    } else {
      gstValidationStatus.value = null;
    }
    calculateCompletion();
  }

  Future<void> validateGSTNumber() async {
    if (gstNumberCtrl.text.isEmpty) return;
    isValidatingGST.value = true;
    gstValidationStatus.value = 'validating';
    try {
      bool isValid = await _authService.validateGST(gstNumberCtrl.text);
      gstValidationStatus.value = isValid ? 'valid' : 'invalid';
    } catch (e) {
      gstValidationStatus.value = 'error';
    } finally {
      isValidatingGST.value = false;
      calculateCompletion();
    }
  }

  void nextStep() {
    if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  bool validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        return companyCtrl.text.isNotEmpty &&
            contactPersonCtrl.text.isNotEmpty &&
            designationCtrl.text.isNotEmpty &&
            GetUtils.isEmail(emailCtrl.text) &&
            GetUtils.isPhoneNumber(mobileCtrl.text) &&
            addressCtrl.text.isNotEmpty;
      case 1:
        return engagementModels.isNotEmpty && timeZones.isNotEmpty && resourceCountCtrl.text.isNotEmpty;
      case 2:
        return bankAccountHolderNameCtrl.text.isNotEmpty && bankAccountNumberCtrl.text.isNotEmpty && bankNameCtrl.text.isNotEmpty && ifscCodeCtrl.text.isNotEmpty;
      case 3:
        return panCard.value != null;
      default:
        return false;
    }
  }

  Future<void> pickPanCard() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg']);
    if (result != null) {
      panCard.value = result.files.first;
      calculateCompletion();
    }
  }

  Future<void> pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png', 'jpeg']);
    if (result != null) {
      avatar.value = result.files.first;
    }
  }

  Future<void> pickCertificates() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg']);
    if (result != null) {
      certificates.addAll(result.files);
    }
  }

  void removeFile(String type, [int? index]) {
    switch (type) {
      case 'panCard':
        panCard.value = null;
        break;
      case 'avatar':
        avatar.value = null;
        break;
      case 'certificate':
        if (index != null) certificates.removeAt(index);
        break;
    }
    calculateCompletion();
  }

  bool isValidBankAccountNumber(String input) {
    final RegExp regex = RegExp(r'^\d{9,18}$');
    return regex.hasMatch(input);
  }

  bool isValidArray(List<String> items) {
    return items.every((item) => item.trim().isNotEmpty);
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) {
      _triggerShake();
      toaster.warning('Please fix the errors in the form');
      return;
    }
    if (!isValidBankAccountNumber(bankAccountNumberCtrl.text)) {
      toaster.warning('Bank account number must be 9 to 18 digits');
      return;
    }
    if (panCard.value == null) {
      _triggerShake();
      toaster.warning('PAN Card is required');
      return;
    }
    if (engagementModels.isNotEmpty && !isValidArray(engagementModels)) {
      toaster.warning('Engagement models must contain valid, non-empty strings');
      return;
    }
    if (timeZones.isNotEmpty && !isValidArray(timeZones)) {
      toaster.warning('Time zones must contain valid, non-empty strings');
      return;
    }
    if (gstValidationStatus.value != 'valid' && gstNumberCtrl.text.isNotEmpty) {
      _triggerShake();
      toaster.warning('Please validate GST number');
      return;
    }
    isLoading.value = true;
    try {
      final request = {
        'company': companyCtrl.text.trim().isNotEmpty ? companyCtrl.text.trim() : null,
        'website': websiteCtrl.text.trim().isNotEmpty ? websiteCtrl.text.trim() : '',
        'address': addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : null,
        'contactPerson': contactPersonCtrl.text.trim().isNotEmpty ? contactPersonCtrl.text.trim() : null,
        'designation': designationCtrl.text.trim().isNotEmpty ? designationCtrl.text.trim() : null,
        'email': emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim().toLowerCase() : null,
        'mobile': mobileCtrl.text.trim().isNotEmpty ? mobileCtrl.text.trim() : null,
        'engagementModels': jsonEncode(engagementModels.map((model) => model.trim()).toList()),
        'resourceCount': resourceCountCtrl.text.trim().isNotEmpty ? int.tryParse(resourceCountCtrl.text.trim()) ?? 1 : 1,
        'timeZones': jsonEncode(timeZones.map((model) => model.trim()).toList()),
        'comments': commentsCtrl.text.trim().isNotEmpty ? commentsCtrl.text.trim() : '',
        'gstNumber': gstNumberCtrl.text.trim().isNotEmpty ? gstNumberCtrl.text.trim() : null,
        'bankDetails': jsonEncode({
          'bankAccountHolderName': bankAccountHolderNameCtrl.text.trim().isNotEmpty ? bankAccountHolderNameCtrl.text.trim() : null,
          'bankAccountNumber': bankAccountNumberCtrl.text.trim(),
          'bankName': bankNameCtrl.text.trim(),
          'ifscCode': ifscCodeCtrl.text.trim(),
          'bankBranchName': bankBranchNameCtrl.text.trim().isNotEmpty ? bankBranchNameCtrl.text.trim() : null,
        }),
      };
      await _authService.updateProfile(request, panCard.value, avatar.value, certificates);
    } catch (e) {
      toaster.error('Failed to update profile: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _triggerShake() {
    shakeForm.value = true;
    Future.delayed(const Duration(milliseconds: 300), () => shakeForm.value = false);
  }
}
