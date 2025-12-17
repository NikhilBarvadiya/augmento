import 'package:augmento/utils/decoration.dart';
import 'package:augmento/utils/toaster.dart';
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
      backgroundColor: decoration.colorScheme.surfaceContainerLowest,
      appBar: _buildAppBar(context),
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return SafeArea(
            child: Column(
              children: [
                _buildProgressHeader(ctrl),
                Expanded(
                  child: SingleChildScrollView(
                    child: Obx(() {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: Matrix4.translationValues(ctrl.shakeForm.value ? (8 * (DateTime.now().millisecondsSinceEpoch % 2 == 0 ? 1 : -1)) : 0, 0, 0),
                        child: Form(key: ctrl.formKey, child: _buildStepContent(ctrl).paddingOnly(top: 20, bottom: 20)),
                      );
                    }),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildProgressHeader(ProfileEditCtrl ctrl) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.timeline_rounded, color: decoration.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Profile Completion',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const Spacer(),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [const Color(0xFF10B981), const Color(0xFF10B981).withOpacity(0.8)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Text(
                    '${(ctrl.completionPercentage.value * 100).toInt()}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(
            () => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: ctrl.completionPercentage.value,
                backgroundColor: decoration.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(decoration.colorScheme.primary),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildStepIndicator(ctrl),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(ProfileEditCtrl ctrl) {
    final steps = [
      {'name': 'Company', 'icon': Icons.business_rounded},
      {'name': 'Business', 'icon': Icons.work_rounded},
      {'name': 'Banking', 'icon': Icons.account_balance_rounded},
      {'name': 'Documents', 'icon': Icons.folder_rounded},
    ];
    return Obx(() {
      return Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = ctrl.currentStep.value > index;
          final isCurrent = ctrl.currentStep.value == index;
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent ? decoration.colorScheme.primary : decoration.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        boxShadow: isCompleted || isCurrent ? [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                            : Icon(steps[index]['icon'] as IconData, color: isCurrent ? Colors.white : const Color(0xFF94A3B8), size: 18),
                      ),
                    ),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(color: isCompleted ? decoration.colorScheme.primary : decoration.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(1)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index]['name'] as String,
                  style: TextStyle(fontSize: 11, fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500, color: isCurrent ? decoration.colorScheme.primary : const Color(0xFF64748B)),
                ),
              ],
            ),
          );
        }),
      );
    });
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

  bool _validateCompanyStep(ProfileEditCtrl ctrl) {
    if (ctrl.companyCtrl.text.trim().isEmpty) {
      _showValidationError('Please enter company name');
      return false;
    }
    if (ctrl.contactPersonCtrl.text.trim().isEmpty) {
      _showValidationError('Please enter contact person name');
      return false;
    }
    if (ctrl.emailCtrl.text.trim().isEmpty) {
      _showValidationError('Please enter email address');
      return false;
    }
    if (!GetUtils.isEmail(ctrl.emailCtrl.text.trim())) {
      _showValidationError('Please enter a valid email address');
      return false;
    }
    if (ctrl.mobileCtrl.text.trim().isEmpty) {
      _showValidationError('Please enter mobile number');
      return false;
    }
    if (ctrl.mobileCtrl.text.trim().length != 10) {
      _showValidationError('Mobile number must be 10 digits');
      return false;
    }
    if (ctrl.gstNumberCtrl.text.trim().isEmpty) {
      _showValidationError('Please enter GST number');
      return false;
    }
    if (ctrl.gstNumberCtrl.text.trim().length != 15) {
      _showValidationError('GST number must be 15 characters');
      return false;
    }
    if (ctrl.gstValidationStatus.value != 'valid') {
      _showValidationError('Please validate GST number');
      return false;
    }
    return true;
  }

  bool _validateBusinessStep(ProfileEditCtrl ctrl) {
    if (ctrl.engagementModels.isEmpty) {
      _showValidationError('Please select at least one engagement model');
      return false;
    }
    if (ctrl.timeZones.isEmpty) {
      _showValidationError('Please select at least one time zone');
      return false;
    }
    if (ctrl.resourceCountCtrl.text.trim().isEmpty) {
      _showValidationError('Please enter available resources count');
      return false;
    }
    return true;
  }

  bool _validateBankingStep(ProfileEditCtrl ctrl) {
    if (ctrl.bankAccountHolderNameCtrl.text.trim().isEmpty) {
      _showValidationError('Please enter account holder name');
      return false;
    }
    if (ctrl.bankAccountNumberCtrl.text.trim().isEmpty) {
      _showValidationError('Please enter account number');
      return false;
    }
    if (ctrl.bankNameCtrl.text.trim().isEmpty) {
      _showValidationError('Please enter bank name');
      return false;
    }
    if (ctrl.bankBranchNameCtrl.text.trim().isEmpty) {
      _showValidationError('Please enter branch name');
      return false;
    }
    if (ctrl.ifscCodeCtrl.text.trim().isEmpty) {
      _showValidationError('Please enter IFSC code');
      return false;
    }
    return true;
  }

  bool _validateDocumentsStep(ProfileEditCtrl ctrl) {
    if (ctrl.panCard.value == null) {
      _showValidationError('Please upload PAN Card');
      return false;
    }
    return true;
  }

  void _showValidationError(String message) => toaster.warning(message);

  Widget _buildCompanyStep(ProfileEditCtrl ctrl) {
    return _buildStepCard(
      'Company Information',
      Icons.business_rounded,
      decoration.colorScheme.primary,
      Column(
        spacing: 16.0,
        children: [
          _buildTextField(controller: ctrl.companyCtrl, label: 'Company Name', icon: Icons.business_rounded, validator: (value) => value?.isEmpty == true ? 'Company name is required' : null),
          _buildTextField(controller: ctrl.contactPersonCtrl, label: 'Contact Person', icon: Icons.person_rounded, validator: (value) => value?.isEmpty == true ? 'Contact person is required' : null),
          _buildTextField(controller: ctrl.designationCtrl, label: 'Designation', icon: Icons.badge_rounded, validator: (value) => value?.isEmpty == true ? 'Designation is required' : null),
          _buildTextField(
            controller: ctrl.emailCtrl,
            label: 'Email Address',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty == true) return 'Email is required';
              if (!GetUtils.isEmail(value!)) return 'Invalid email format';
              return null;
            },
          ),
          _buildTextField(
            controller: ctrl.mobileCtrl,
            label: 'Mobile Number',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (value) {
              if (value?.isEmpty == true) return 'Mobile number is required';
              if (value!.length != 10) return 'Enter 10 digit mobile number';
              return null;
            },
          ),
          _buildTextField(controller: ctrl.websiteCtrl, label: 'Website URL (Optional)', icon: Icons.language_rounded, keyboardType: TextInputType.url),
          _buildTextField(
            controller: ctrl.addressCtrl,
            label: 'Company Address',
            icon: Icons.location_on_rounded,
            maxLines: 2,
            validator: (value) => value?.isEmpty == true ? 'Address is required' : null,
          ),
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
          if (value?.isEmpty == true) return 'GST number is required';
          if (value!.length != 15) return 'GST number must be 15 characters';
          return null;
        },
        decoration: InputDecoration(
          counterText: "",
          labelText: 'GST Number *',
          prefixIcon: Icon(Icons.receipt_long_rounded, size: 20, color: decoration.colorScheme.onSurfaceVariant),
          suffixIcon: ctrl.isValidatingGST.value
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : ctrl.gstValidationStatus.value == 'valid'
              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981))
              : ctrl.gstValidationStatus.value == 'invalid'
              ? const Icon(Icons.error_rounded, color: Color(0xFFEF4444))
              : ctrl.gstNumberCtrl.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.search_rounded, color: decoration.colorScheme.primary),
                  onPressed: ctrl.validateGSTNumber,
                )
              : null,
          labelStyle: TextStyle(color: decoration.colorScheme.onSurfaceVariant, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: ctrl.gstValidationStatus.value == 'invalid' ? const Color(0xFFEF4444) : decoration.colorScheme.outline.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: ctrl.gstValidationStatus.value == 'valid'
                  ? const Color(0xFF10B981)
                  : ctrl.gstValidationStatus.value == 'invalid'
                  ? const Color(0xFFEF4444)
                  : decoration.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: decoration.colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildBusinessStep(ProfileEditCtrl ctrl) {
    return _buildStepCard(
      'Business Details',
      Icons.work_rounded,
      const Color(0xFF10B981),
      Column(
        children: [
          _buildMultiSelectChipField(items: const ['Remote', 'Onsite', 'Hybrid'], selectedItems: ctrl.engagementModels, label: 'Engagement Models', icon: Icons.handshake_rounded),
          const SizedBox(height: 16),
          _buildMultiSelectChipField(items: const ['IST', 'UTC', 'PST', 'EST', 'CST', 'JST'], selectedItems: ctrl.timeZones, label: 'Available Time Zones', icon: Icons.schedule_rounded),
          const SizedBox(height: 16),
          _buildTextField(
            controller: ctrl.resourceCountCtrl,
            label: 'Available Resources',
            icon: Icons.people_alt_rounded,
            keyboardType: TextInputType.number,
            validator: (value) => value?.isEmpty == true ? 'Resource count is required' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(controller: ctrl.commentsCtrl, label: 'Additional Comments (Optional)', icon: Icons.comment_rounded, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildBankingStep(ProfileEditCtrl ctrl) {
    return _buildStepCard(
      'Banking Information',
      Icons.account_balance_rounded,
      const Color(0xFF8B5CF6),
      Column(
        spacing: 16.0,
        children: [
          _buildTextField(
            controller: ctrl.bankAccountHolderNameCtrl,
            label: 'Account Holder Name',
            icon: Icons.person_rounded,
            validator: (value) => value?.isEmpty == true ? 'Account holder name is required' : null,
          ),
          _buildTextField(
            controller: ctrl.bankAccountNumberCtrl,
            label: 'Account Number',
            icon: Icons.account_balance_wallet_rounded,
            keyboardType: TextInputType.number,
            validator: (value) => value?.isEmpty == true ? 'Account number is required' : null,
          ),
          _buildTextField(controller: ctrl.bankNameCtrl, label: 'Bank Name', icon: Icons.account_balance_rounded, validator: (value) => value?.isEmpty == true ? 'Bank name is required' : null),
          _buildTextField(
            controller: ctrl.bankBranchNameCtrl,
            label: 'Branch Name',
            icon: Icons.location_city_rounded,
            validator: (value) => value?.isEmpty == true ? 'Branch name is required' : null,
          ),
          _buildTextField(controller: ctrl.ifscCodeCtrl, label: 'IFSC Code', icon: Icons.code_rounded, validator: (value) => value?.isEmpty == true ? 'IFSC code is required' : null),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep(ProfileEditCtrl ctrl) {
    return _buildStepCard(
      'Documents & Files',
      Icons.folder_rounded,
      const Color(0xFFF59E0B),
      Column(
        children: [
          _buildFileUploadField(label: 'PAN Card', file: ctrl.panCard, onTap: ctrl.pickPanCard, onRemove: () => ctrl.removeFile('panCard'), icon: Icons.credit_card_rounded, required: true),
          const SizedBox(height: 16),
          _buildFileUploadField(label: 'Profile Avatar', file: ctrl.avatar, onTap: ctrl.pickAvatar, onRemove: () => ctrl.removeFile('avatar'), icon: Icons.person_rounded),
          const SizedBox(height: 16),
          _buildMultiFileUploadField(
            label: 'Certificates',
            files: ctrl.certificates,
            onTap: ctrl.pickCertificates,
            onRemove: (index) => ctrl.removeFile('certificate', index),
            icon: Icons.verified_rounded,
          ),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 22),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: Obx(
        () => Row(
          children: [
            if (ctrl.currentStep.value > 0) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ctrl.currentStep.value--;
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: decoration.colorScheme.outline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: ctrl.currentStep.value == 0 ? 1 : 2,
              child: ctrl.currentStep.value == 3
                  ? Obx(
                      () => ElevatedButton(
                        onPressed: ctrl.isLoading.value
                            ? null
                            : () {
                                if (_validateDocumentsStep(ctrl)) {
                                  ctrl.updateProfile();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: decoration.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: ctrl.isLoading.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text('Update Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        bool isValid = false;
                        switch (ctrl.currentStep.value) {
                          case 0:
                            isValid = _validateCompanyStep(ctrl);
                            break;
                          case 1:
                            isValid = _validateBusinessStep(ctrl);
                            break;
                          case 2:
                            isValid = _validateBankingStep(ctrl);
                            break;
                        }
                        if (isValid) {
                          ctrl.currentStep.value++;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: decoration.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Next Step', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
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
        prefixIcon: Icon(icon, size: 20, color: decoration.colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: decoration.colorScheme.onSurfaceVariant, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: decoration.colorScheme.outline.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: decoration.colorScheme.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: decoration.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildMultiSelectChipField({required List<String> items, required RxList<String> selectedItems, required String label, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: decoration.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
            ),
            const Text(' *', style: TextStyle(color: Color(0xFFEF4444))),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selectedItems.isEmpty ? const Color(0xFFEF4444).withOpacity(0.5) : decoration.colorScheme.outline.withOpacity(0.3)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Obx(
                () => FilterChip(
                  label: Text(
                    item,
                    style: TextStyle(fontSize: 13, color: selectedItems.contains(item) ? decoration.colorScheme.primary : const Color(0xFF64748B), fontWeight: FontWeight.w500),
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
                  selectedColor: decoration.colorScheme.primary.withOpacity(0.12),
                  checkmarkColor: decoration.colorScheme.primary,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: selectedItems.contains(item) ? decoration.colorScheme.primary : decoration.colorScheme.outline.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              );
            }).toList(),
          ),
        ),
        if (selectedItems.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 12),
            child: Text('Please select at least one option', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildFileUploadField({required String label, required Rx<PlatformFile?> file, required VoidCallback onTap, required VoidCallback onRemove, required IconData icon, bool required = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: required && file.value == null ? const Color(0xFFEF4444).withOpacity(0.5) : decoration.colorScheme.outline.withOpacity(0.3)),
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
                      icon: Icon(Icons.refresh_rounded, color: decoration.colorScheme.primary, size: 20),
                    ),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444), size: 20),
                    ),
                  ],
                ),
              )
            : ListTile(
                leading: Icon(icon, color: decoration.colorScheme.onSurfaceVariant),
                title: Text(
                  label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: required && file.value == null ? const Color(0xFFEF4444) : decoration.colorScheme.onSurface),
                ),
                subtitle: Text(
                  required && file.value == null ? 'Required' : 'Tap to upload',
                  style: TextStyle(color: required && file.value == null ? const Color(0xFFEF4444) : decoration.colorScheme.onSurfaceVariant, fontSize: 12),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'Upload',
                    style: TextStyle(color: decoration.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: decoration.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: decoration.colorScheme.onSurfaceVariant),
            title: Obx(
              () => Text(
                files.isEmpty ? label : '${files.length} files selected',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: files.isNotEmpty ? const Color(0xFF10B981) : decoration.colorScheme.onSurface),
              ),
            ),
            subtitle: const Text('Tap to add more files', style: TextStyle(fontSize: 12)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(
                'Add Files',
                style: TextStyle(color: decoration.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
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
                Divider(height: 1, color: decoration.colorScheme.outline.withOpacity(0.2)),
                ...List.generate(files.length, (index) {
                  final file = files[index] as PlatformFile;
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.description_rounded, color: Color(0xFF10B981), size: 20),
                    title: Text(file.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                    subtitle: Text('${(file.size / 1024 / 1024).toStringAsFixed(2)} MB', style: const TextStyle(fontSize: 10)),
                    trailing: IconButton(
                      onPressed: () => onRemove(index),
                      icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 16),
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
