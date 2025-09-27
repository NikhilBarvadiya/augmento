import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/account/profile_edit/profile_edit_ctrl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class ProfileEdit extends StatelessWidget {
  const ProfileEdit({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ProfileEditCtrl());
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return SafeArea(
            child: Column(
              children: [
                _buildProgressHeader(ctrl),
                Expanded(
                  child: SingleChildScrollView(
                    child: Obx(
                      () => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: Matrix4.translationValues(ctrl.shakeForm.value ? (8 * (DateTime.now().millisecondsSinceEpoch % 2 == 0 ? 1 : -1)) : 0, 0, 0),
                        child: Form(key: ctrl.formKey, child: _buildStepContent(ctrl).paddingOnly(top: 20, bottom: 20)),
                      ),
                    ),
                  ),
                ),
                if (!isKeyboardVisible) _buildBottomNavigation(ctrl),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [decoration.colorScheme.primary, decoration.colorScheme.secondary]),
        ),
      ),
      title: const Text(
        'Edit Profile',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildProgressHeader(ProfileEditCtrl ctrl) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timeline, color: Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              const Text(
                'Profile Completion',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
              const Spacer(),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${(ctrl.completionPercentage.value * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => LinearProgressIndicator(
              value: ctrl.completionPercentage.value,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          _buildStepIndicator(ctrl),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(ProfileEditCtrl ctrl) {
    final steps = ['Company', 'Business', 'Banking', 'Documents'];
    return Row(
      children: List.generate(steps.length, (index) {
        return Expanded(
          child: Row(
            children: [
              Obx(
                () => Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: ctrl.currentStep.value >= index ? decoration.colorScheme.primary : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: ctrl.currentStep.value > index
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(color: ctrl.currentStep.value >= index ? Colors.white : const Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                  ),
                ),
              ),
              if (index < steps.length - 1) ...[
                const SizedBox(width: 8),
                Expanded(child: Container(height: 2, color: ctrl.currentStep.value > index ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0))),
                const SizedBox(width: 8),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent(ProfileEditCtrl ctrl) {
    return Obx(() {
      switch (ctrl.currentStep.value) {
        case 0:
          return _buildCompanyStep(ctrl);
        case 1:
          return _buildBusinessStep(ctrl);
        case 2:
          return _buildBankingStep(ctrl);
        case 3:
          return _buildDocumentsStep(ctrl);
        default:
          return _buildCompanyStep(ctrl);
      }
    });
  }

  Widget _buildCompanyStep(ProfileEditCtrl ctrl) {
    return _buildStepCard(
      'Company Information',
      Icons.business,
      const Color(0xFF3B82F6),
      Column(
        children: [
          _buildTextField(controller: ctrl.companyCtrl, label: 'Company Name', icon: Icons.business, validator: (value) => value?.isEmpty == true ? 'Company name is required' : null),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: ctrl.contactPersonCtrl,
                  label: 'Contact Person',
                  icon: Icons.person,
                  validator: (value) => value?.isEmpty == true ? 'Contact person is required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(controller: ctrl.designationCtrl, label: 'Designation', icon: Icons.badge, validator: (value) => value?.isEmpty == true ? 'Designation is required' : null),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: ctrl.emailCtrl,
                  label: 'Email Address',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Email is required';
                    if (!GetUtils.isEmail(value!)) return 'Invalid email format';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: ctrl.mobileCtrl,
                  label: 'Mobile Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Mobile number is required';
                    if (value!.length != 10) return 'Enter 10 digit mobile number';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller: ctrl.websiteCtrl, label: 'Website URL (Optional)', icon: Icons.language, keyboardType: TextInputType.url),
          const SizedBox(height: 16),
          _buildTextField(controller: ctrl.addressCtrl, label: 'Company Address', icon: Icons.location_on, maxLines: 2, validator: (value) => value?.isEmpty == true ? 'Address is required' : null),
          const SizedBox(height: 16),
          _buildGSTField(ctrl),
        ],
      ),
    );
  }

  Widget _buildGSTField(ProfileEditCtrl ctrl) {
    return Obx(
      () => TextFormField(
        controller: ctrl.gstNumberCtrl,
        maxLength: 15,
        style: const TextStyle(fontSize: 14),
        validator: (value) {
          if (value?.isNotEmpty == true && value!.length != 15) {
            return 'GST number must be 15 characters';
          }
          return null;
        },
        decoration: InputDecoration(
          counterText: "",
          labelText: 'GST Number (Required)',
          prefixIcon: const Icon(Icons.receipt_long, size: 20, color: Color(0xFF64748B)),
          suffixIcon: ctrl.isValidatingGST.value
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : ctrl.gstValidationStatus.value == 'valid'
              ? const Icon(Icons.check_circle, color: Color(0xFF10B981))
              : ctrl.gstValidationStatus.value == 'invalid'
              ? const Icon(Icons.error, color: Color(0xFFEF4444))
              : ctrl.gstNumberCtrl.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.search), onPressed: ctrl.validateGSTNumber)
              : null,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ctrl.gstValidationStatus.value == 'invalid' ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ctrl.gstValidationStatus.value == 'valid'
                  ? const Color(0xFF10B981)
                  : ctrl.gstValidationStatus.value == 'invalid'
                  ? const Color(0xFFEF4444)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBusinessStep(ProfileEditCtrl ctrl) {
    return _buildStepCard(
      'Business Details',
      Icons.work_outline,
      const Color(0xFF10B981),
      Column(
        children: [
          _buildMultiSelectChipField(items: const ['Remote', 'Onsite', 'Hybrid'], selectedItems: ctrl.engagementModels, label: 'Engagement Models', icon: Icons.handshake_outlined),
          const SizedBox(height: 16),
          _buildMultiSelectChipField(items: const ['IST', 'UTC', 'PST', 'EST', 'CST', 'JST'], selectedItems: ctrl.timeZones, label: 'Available Time Zones', icon: Icons.schedule),
          const SizedBox(height: 16),
          _buildTextField(
            controller: ctrl.resourceCountCtrl,
            label: 'Available Resources',
            icon: Icons.people_alt,
            keyboardType: TextInputType.number,
            validator: (value) => value?.isEmpty == true ? 'Resource count is required' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(controller: ctrl.commentsCtrl, label: 'Additional Comments (Optional)', icon: Icons.comment, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildBankingStep(ProfileEditCtrl ctrl) {
    return _buildStepCard(
      'Banking Information',
      Icons.account_balance,
      const Color(0xFF8B5CF6),
      Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: ctrl.bankAccountHolderNameCtrl,
                  label: 'Account Holder Name',
                  icon: Icons.person,
                  validator: (value) => value?.isEmpty == true ? 'Account holder name is required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: ctrl.bankAccountNumberCtrl,
                  label: 'Account Number',
                  icon: Icons.account_balance_wallet,
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty == true ? 'Account number is required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(controller: ctrl.bankNameCtrl, label: 'Bank Name', icon: Icons.account_balance, validator: (value) => value?.isEmpty == true ? 'Bank name is required' : null),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: ctrl.bankBranchNameCtrl,
                  label: 'Branch Name',
                  icon: Icons.location_city,
                  validator: (value) => value?.isEmpty == true ? 'Branch name is required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller: ctrl.ifscCodeCtrl, label: 'IFSC Code', icon: Icons.code, validator: (value) => value?.isEmpty == true ? 'IFSC code is required' : null),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep(ProfileEditCtrl ctrl) {
    return _buildStepCard(
      'Documents & Files',
      Icons.folder_outlined,
      const Color(0xFFF59E0B),
      Column(
        children: [
          _buildFileUploadField(label: 'PAN Card', file: ctrl.panCard, onTap: ctrl.pickPanCard, onRemove: () => ctrl.removeFile('panCard'), icon: Icons.credit_card, required: true),
          const SizedBox(height: 16),
          _buildFileUploadField(label: 'Profile Avatar', file: ctrl.avatar, onTap: ctrl.pickAvatar, onRemove: () => ctrl.removeFile('avatar'), icon: Icons.person),
          const SizedBox(height: 16),
          _buildMultiFileUploadField(label: 'Certificates', files: ctrl.certificates, onTap: ctrl.pickCertificates, onRemove: (index) => ctrl.removeFile('certificate', index), icon: Icons.verified),
        ],
      ),
    );
  }

  Widget _buildStepCard(String title, IconData icon, Color color, Widget content) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: content),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(ProfileEditCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Obx(
        () => Row(
          children: [
            if (ctrl.currentStep.value > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: ctrl.previousStep,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: decoration.colorScheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(color: decoration.colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ctrl.currentStep.value == 3
                  ? Obx(
                      () => ElevatedButton(
                        onPressed: ctrl.isLoading.value ? null : ctrl.updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: decoration.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: ctrl.isLoading.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Text('Update Profile', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: ctrl.nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: decoration.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Next Step', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      onChanged: (_) {
        if (Get.isRegistered<ProfileEditCtrl>()) {
          Get.find<ProfileEditCtrl>().calculateCompletion();
        }
      },
      decoration: InputDecoration(
        counterText: "",
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildMultiSelectChipField({required List<String> items, required RxList<String> selectedItems, required String label, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
            ),
            if (selectedItems.isEmpty) const Text(' *', style: TextStyle(color: Color(0xFFEF4444))),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selectedItems.isEmpty ? const Color(0xFFEF4444).withOpacity(0.5) : const Color(0xFFE2E8F0)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Obx(
                () => FilterChip(
                  label: Text(
                    item,
                    style: TextStyle(fontSize: 12, color: selectedItems.contains(item) ? const Color(0xFF3B82F6) : const Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                  selected: selectedItems.contains(item),
                  onSelected: (selected) {
                    HapticFeedback.lightImpact();
                    if (selected) {
                      selectedItems.add(item);
                    } else {
                      selectedItems.remove(item);
                    }
                    if (Get.isRegistered<ProfileEditCtrl>()) {
                      Get.find<ProfileEditCtrl>().calculateCompletion();
                    }
                  },
                  selectedColor: const Color(0xFF3B82F6).withOpacity(0.1),
                  checkmarkColor: const Color(0xFF3B82F6),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: selectedItems.contains(item) ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              );
            }).toList(),
          ),
        ),
        if (selectedItems.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 12),
            child: Text('Please select at least one option', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildFileUploadField({required String label, required Rx<PlatformFile?> file, required VoidCallback onTap, required VoidCallback onRemove, required IconData icon, bool required = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: required && file.value == null ? const Color(0xFFEF4444).withOpacity(0.5) : const Color(0xFFE2E8F0)),
      ),
      child: Obx(
        () => file.value != null
            ? ListTile(
                leading: Icon(icon, color: const Color(0xFF10B981)),
                title: Text(
                  file.value!.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF10B981)),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('${(file.value!.size / 1024 / 1024).toStringAsFixed(2)} MB', style: const TextStyle(fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onTap,
                      icon: const Icon(Icons.refresh, color: Color(0xFF3B82F6), size: 20),
                    ),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 20),
                    ),
                  ],
                ),
              )
            : ListTile(
                leading: Icon(icon, color: const Color(0xFF64748B)),
                title: Text(
                  label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: required && file.value == null ? const Color(0xFFEF4444) : const Color(0xFF64748B)),
                ),
                subtitle: required && file.value == null
                    ? const Text('Required', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12))
                    : const Text('Tap to upload', style: TextStyle(fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: const Text(
                    'Upload',
                    style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
              ),
      ),
    );
  }

  Widget _buildMultiFileUploadField({required String label, required RxList files, required VoidCallback onTap, required Function(int) onRemove, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: const Color(0xFF64748B)),
            title: Obx(
              () => Text(
                files.isEmpty ? label : '${files.length} files selected',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: files.isNotEmpty ? const Color(0xFF10B981) : const Color(0xFF64748B)),
              ),
            ),
            subtitle: const Text('Tap to add more files', style: TextStyle(fontSize: 12)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: const Text(
                'Add Files',
                style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
          ),
          Obx(() {
            if (files.isEmpty) return const SizedBox.shrink();

            return Column(
              children: [
                const Divider(height: 1),
                ...List.generate(files.length, (index) {
                  final file = files[index] as PlatformFile;
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.description, color: Color(0xFF10B981), size: 20),
                    title: Text(file.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                    subtitle: Text('${(file.size / 1024 / 1024).toStringAsFixed(2)} MB', style: const TextStyle(fontSize: 10)),
                    trailing: IconButton(
                      onPressed: () => onRemove(index),
                      icon: const Icon(Icons.close, color: Color(0xFFEF4444), size: 16),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }
}
