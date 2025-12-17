import 'package:augmento/utils/decoration.dart';
import 'package:augmento/utils/network/api_config.dart';
import 'package:augmento/views/dashboard/tabs/candidates/candidates_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class CandidateForm extends StatelessWidget {
  final Map<String, dynamic>? candidate;
  final bool isEdit;

  const CandidateForm({super.key, this.candidate, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CandidatesCtrl>(
      builder: (ctrl) {
        if (isEdit && candidate != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _populateForm(ctrl);
          });
        }
        return KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: _buildAppBar(),
              body: _buildBody(context, ctrl),
              bottomNavigationBar: !isKeyboardVisible ? _buildBottomBar(context, ctrl) : SizedBox.shrink(),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(isEdit ? 'Edit Candidate' : 'Add New Candidate', style: const TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: decoration.colorScheme.primary,
      foregroundColor: decoration.colorScheme.onPrimary,
    );
  }

  Widget _buildBody(BuildContext context, CandidatesCtrl ctrl) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileSection(ctrl),
          _buildPersonalInfoSection(ctrl),
          _buildProfessionalInfoSection(ctrl),
          _buildFinancialInfoSection(ctrl),
          _buildStatusSection(ctrl),
          _buildDocumentSection(ctrl),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileSection(CandidatesCtrl ctrl) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Obx(
            () => GestureDetector(
              onTap: () => ctrl.pickFile('profileImage'),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: ctrl.profileImage.value != null
                    ? ClipOval(child: Icon(Icons.person, size: 40, color: Colors.grey[600]))
                    : isEdit && candidate?['profileImage'] != null
                    ? ClipOval(
                        child: Image.network(
                          '${APIConfig.resourceBaseURL}/${candidate!['profileImage']}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 40, color: Colors.grey[600]),
                        ),
                      )
                    : Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Profile Photo',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text('Tap to upload', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(CandidatesCtrl ctrl) {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        _buildFormField(controller: ctrl.nameCtrl, label: 'Full Name', icon: Icons.person, isRequired: true),
        _buildFormField(controller: ctrl.mobileCtrl, label: 'Mobile Number', icon: Icons.phone, keyboardType: TextInputType.phone, isRequired: true),
        _buildMultiSelectField(txtController: ctrl.educationCtrl, ctrl: ctrl, fieldType: 'education', label: 'Education', icon: Icons.school, hint: 'Add education qualifications'),
      ],
    );
  }

  Widget _buildProfessionalInfoSection(CandidatesCtrl ctrl) {
    return _buildSection(
      title: 'Professional Information',
      icon: Icons.work_outline,
      children: [
        _buildMultiSelectField(txtController: ctrl.skillsCtrl, ctrl: ctrl, fieldType: 'skills', label: 'Skills', icon: Icons.code, hint: 'Add technical skills', isRequired: true),
        _buildMultiSelectField(txtController: ctrl.techStackCtrl, ctrl: ctrl, fieldType: 'techStack', label: 'Tech Stack', icon: Icons.computer, hint: 'Add technology stack'),
        _buildFormField(controller: ctrl.experienceCtrl, label: 'Experience (Years)', icon: Icons.timeline, keyboardType: TextInputType.number, isRequired: true),
        _buildAvailabilityDropdown(ctrl),
      ],
    );
  }

  Widget _buildFinancialInfoSection(CandidatesCtrl ctrl) {
    return _buildSection(
      title: 'Financial Information',
      icon: Icons.monetization_on_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFormField(controller: ctrl.currentSalaryCtrl, label: 'Current Salary', icon: Icons.attach_money, keyboardType: TextInputType.number, hint: 'Monthly amount'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(controller: ctrl.chargesCtrl, label: 'Expected Charges', icon: Icons.price_change, keyboardType: TextInputType.number, hint: 'Monthly amount'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusSection(CandidatesCtrl ctrl) {
    return _buildSection(
      title: 'Status & Settings',
      icon: Icons.settings_outlined,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            children: [
              Obx(
                () => SwitchListTile(
                  title: const Text('IT Futurz Candidate', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('Mark as internal candidate'),
                  value: ctrl.isCandidate.value,
                  onChanged: (value) => ctrl.isCandidate.value = value,
                  contentPadding: EdgeInsets.zero,
                  activeColor: decoration.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: ctrl.candidateStatus.value,
                  decoration: InputDecoration(
                    labelText: 'Availability Status',
                    prefixIcon: const Icon(Icons.info_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: ['Available', 'Not Available'].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                  onChanged: (value) => ctrl.candidateStatus.value = value ?? 'Available',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentSection(CandidatesCtrl ctrl) {
    return _buildSection(
      title: 'Documents',
      icon: Icons.description_outlined,
      children: [
        Obx(
          () => _buildFileUploadCard(
            title: 'Resume',
            subtitle: 'Upload candidate resume (PDF preferred)',
            fileName: ctrl.resume.value?.name,
            icon: Icons.description,
            onTap: () => ctrl.pickFile('resume'),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectField({
    required TextEditingController txtController,
    required CandidatesCtrl ctrl,
    required String fieldType,
    required String label,
    required IconData icon,
    required String hint,
    bool isRequired = false,
  }) {
    RxList<String> items = _getFieldItems(ctrl, fieldType);
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label${isRequired ? ' *' : ''}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isRequired ? Colors.red[700] : Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  items.isEmpty
                      ? Text(hint, style: TextStyle(color: Colors.grey[600], fontSize: 14))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: items.map((item) => _buildChip(label: item, onDeleted: () => _removeItem(ctrl, fieldType, item))).toList(),
                        ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: txtController,
                          decoration: InputDecoration(
                            hintText: 'Type and press Enter to add',
                            hintStyle: TextStyle(fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            prefixIcon: Icon(icon, size: 20),
                            suffixIcon: IconButton(
                              onPressed: () {
                                if (txtController.text.trim().isNotEmpty) {
                                  _addItem(ctrl, fieldType, txtController.text.toString().trim());
                                  txtController.clear();
                                }
                              },
                              icon: Icon(Icons.add),
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              txtController.clear();
                              _addItem(ctrl, fieldType, value.trim());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChip({required String label, required VoidCallback onDeleted}) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onDeleted: onDeleted,
      backgroundColor: Colors.blue[100],
      deleteIconColor: Colors.blue[700],
      labelStyle: TextStyle(color: Colors.blue[800]),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildAvailabilityDropdown(CandidatesCtrl ctrl) {
    return DropdownButtonFormField<String>(
      value: ctrl.availabilityCtrl.text.isEmpty ? null : ctrl.availabilityCtrl.text,
      decoration: InputDecoration(
        labelText: 'Availability',
        prefixIcon: const Icon(Icons.schedule, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: decoration.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: ['Immediate', '1 Week', '2 Weeks', '1 Month', 'Other'].map((availability) => DropdownMenuItem(value: availability, child: Text(availability))).toList(),
      onChanged: (value) {
        ctrl.availabilityCtrl.text = value ?? '';
      },
      hint: const Text('Select availability'),
    );
  }

  RxList<String> _getFieldItems(CandidatesCtrl ctrl, String fieldType) {
    switch (fieldType) {
      case 'skills':
        return ctrl.skillsList;
      case 'techStack':
        return ctrl.techStackList;
      case 'education':
        return ctrl.educationList;
      default:
        return <String>[].obs;
    }
  }

  void _addItem(CandidatesCtrl ctrl, String fieldType, String item) {
    switch (fieldType) {
      case 'skills':
        if (!ctrl.skillsList.contains(item)) {
          ctrl.skillsList.add(item);
        }
        break;
      case 'techStack':
        if (!ctrl.techStackList.contains(item)) {
          ctrl.techStackList.add(item);
        }
        break;
      case 'education':
        if (!ctrl.educationList.contains(item)) {
          ctrl.educationList.add(item);
        }
        break;
    }
  }

  void _removeItem(CandidatesCtrl ctrl, String fieldType, String item) {
    switch (fieldType) {
      case 'skills':
        ctrl.skillsList.remove(item);
        break;
      case 'techStack':
        ctrl.techStackList.remove(item);
        break;
      case 'education':
        ctrl.educationList.remove(item);
        break;
    }
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 20, color: decoration.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hint,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: keyboardType == TextInputType.phone ? 10 : null,
        decoration: InputDecoration(
          counterText: "",
          labelText: '$label${isRequired ? ' *' : ''}',
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: decoration.colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: isRequired ? Colors.red[700] : Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildFileUploadCard({required String title, required String subtitle, String? fileName, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: fileName != null ? Colors.green[300]! : Colors.grey[300]!, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
          color: fileName != null ? Colors.green[50] : Colors.grey[50],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: fileName != null ? Colors.green[100] : Colors.grey[200], borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: fileName != null ? Colors.green[700] : Colors.grey[600], size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName ?? title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: fileName != null ? Colors.green[800] : Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(fileName != null ? 'File selected' : subtitle, style: TextStyle(fontSize: 12, color: fileName != null ? Colors.green[600] : Colors.grey[600])),
                ],
              ),
            ),
            Icon(fileName != null ? Icons.check_circle : Icons.upload_file, color: fileName != null ? Colors.green[600] : Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CandidatesCtrl ctrl) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.close(1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Obx(
                () => ElevatedButton(
                  onPressed: ctrl.isLoading.value ? null : () => _handleSubmit(ctrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: decoration.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: ctrl.isLoading.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          isEdit ? 'Update Candidate' : 'Create Candidate',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _populateForm(CandidatesCtrl ctrl) {
    if (candidate == null) return;
    ctrl.nameCtrl.text = candidate!['name'] ?? '';
    ctrl.mobileCtrl.text = candidate!['mobile'] ?? '';
    ctrl.experienceCtrl.text = candidate!['experience']?.toString() ?? '';
    ctrl.availabilityCtrl.text = candidate!['availability'] ?? '';
    ctrl.chargesCtrl.text = candidate!['charges']?.toString() ?? '';
    ctrl.currentSalaryCtrl.text = candidate!['currentSalary']?.toString() ?? '';
    ctrl.isCandidate.value = candidate!['itfuturzCandidate'] ?? false;
    ctrl.candidateStatus.value = candidate!['status'] ?? 'Available';
    if (candidate!['skills'] != null) {
      ctrl.skillsList.value = List<String>.from(candidate!['skills']);
    }
    if (candidate!['techStack'] != null) {
      ctrl.techStackList.value = List<String>.from(candidate!['techStack']);
    }
    if (candidate!['education'] != null) {
      ctrl.educationList.value = List<String>.from(candidate!['education']);
    }
  }

  void _handleSubmit(CandidatesCtrl ctrl) {
    if (_validateForm(ctrl)) {
      if (isEdit) {
        ctrl.createCandidate(candidateId: candidate!['_id']);
      } else {
        ctrl.createCandidate();
      }
    }
  }

  bool _validateForm(CandidatesCtrl ctrl) {
    if (ctrl.nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter candidate name', backgroundColor: Colors.red[100], colorText: Colors.red[800]);
      return false;
    }
    if (ctrl.mobileCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter mobile number', backgroundColor: Colors.red[100], colorText: Colors.red[800]);
      return false;
    }
    if (ctrl.skillsList.isEmpty) {
      Get.snackbar('Validation Error', 'Please add at least one skill', backgroundColor: Colors.red[100], colorText: Colors.red[800]);
      return false;
    }
    return true;
  }
}
