import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/candidate_requirements/candidate_requirements_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class RequirementForm extends StatelessWidget {
  final Map<String, dynamic>? requirement;
  final bool isEdit;

  const RequirementForm({super.key, this.requirement, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CandidateRequirementsCtrl>(
      builder: (ctrl) {
        if (isEdit && requirement != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ctrl.populateForm(requirement!);
          });
        }
        return KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: _buildAppBar(),
              body: _buildBody(context, ctrl),
              bottomNavigationBar: !isKeyboardVisible ? _buildBottomBar(context, ctrl) : const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(isEdit ? 'Edit Job Requirement' : 'Add New Job Requirement', style: const TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: decoration.colorScheme.primary,
      foregroundColor: decoration.colorScheme.onPrimary,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildBody(BuildContext context, CandidateRequirementsCtrl ctrl) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBasicInfoSection(ctrl),
          _buildSkillsQualificationsSection(ctrl),
          _buildJobDetailsSection(ctrl),
          _buildSalaryInfoSection(ctrl),
          _buildStatusSection(ctrl),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(CandidateRequirementsCtrl ctrl) {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        _buildFormField(controller: ctrl.jobTitleCtrl, label: 'Job Title', icon: Icons.work, isRequired: true),
        _buildDropdownField(controller: ctrl.jobTypeCtrl, label: 'Job Type', icon: Icons.schedule, items: ['Full-time', 'Part-time', 'Contract', 'Internship'], isRequired: true),
        _buildDropdownField(controller: ctrl.experienceLevelCtrl, label: 'Experience Level', icon: Icons.trending_up, items: ['Entry', 'Mid', 'Senior', 'Lead'], isRequired: true),
        _buildFormField(controller: ctrl.locationCtrl, label: 'Location', icon: Icons.location_on, isRequired: true),
      ],
    );
  }

  Widget _buildSkillsQualificationsSection(CandidateRequirementsCtrl ctrl) {
    return _buildSection(
      title: 'Skills & Qualifications',
      icon: Icons.psychology_outlined,
      children: [
        _buildMultiSelectField(
          txtController: ctrl.requiredSkillsCtrl,
          ctrl: ctrl,
          fieldType: 'requiredSkills',
          label: 'Required Skills',
          icon: Icons.star,
          hint: 'Add required skills',
          isRequired: true,
        ),
        _buildMultiSelectField(txtController: ctrl.preferredSkillsCtrl, ctrl: ctrl, fieldType: 'preferredSkills', label: 'Preferred Skills', icon: Icons.star_border, hint: 'Add preferred skills'),
        _buildMultiSelectField(txtController: ctrl.certificationCtrl, ctrl: ctrl, fieldType: 'certification', label: 'Certifications', icon: Icons.verified, hint: 'Add certifications'),
        _buildMultiSelectField(
          txtController: ctrl.educationQualificationCtrl,
          ctrl: ctrl,
          fieldType: 'educationQualification',
          label: 'Education Qualifications',
          icon: Icons.school,
          hint: 'Add education qualifications',
          isRequired: true,
        ),
        _buildMultiSelectField(txtController: ctrl.softSkillsCtrl, ctrl: ctrl, fieldType: 'softSkills', label: 'Soft Skills', icon: Icons.people, hint: 'Add soft skills', isRequired: true),
        _buildMultiSelectField(txtController: ctrl.techStackCtrl, ctrl: ctrl, fieldType: 'techStack', label: 'Tech Stack', icon: Icons.code, hint: 'Add tech stack'),
      ],
    );
  }

  Widget _buildJobDetailsSection(CandidateRequirementsCtrl ctrl) {
    return _buildSection(
      title: 'Job Details',
      icon: Icons.description_outlined,
      children: [
        _buildFormField(controller: ctrl.responsibilityCtrl, label: 'Responsibilities', icon: Icons.task_alt, maxLines: 3, isRequired: true),
        _buildFormField(controller: ctrl.summaryCtrl, label: 'Job Summary', icon: Icons.summarize, maxLines: 3, isRequired: true),
      ],
    );
  }

  Widget _buildSalaryInfoSection(CandidateRequirementsCtrl ctrl) {
    return _buildSection(
      title: 'Salary Information',
      icon: Icons.monetization_on_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFormField(controller: ctrl.salaryMinCtrl, label: 'Min Salary', icon: Icons.attach_money, keyboardType: TextInputType.number, isRequired: true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(controller: ctrl.salaryMaxCtrl, label: 'Max Salary', icon: Icons.attach_money, keyboardType: TextInputType.number, isRequired: true),
            ),
          ],
        ),
        _buildDropdownField(controller: ctrl.salaryCurrencyCtrl, label: 'Currency', icon: Icons.currency_exchange, items: ['USD', 'EUR', 'GBP', 'INR'], isRequired: true),
      ],
    );
  }

  Widget _buildStatusSection(CandidateRequirementsCtrl ctrl) {
    return _buildSection(
      title: 'Status',
      icon: Icons.settings_outlined,
      children: [
        Obx(
          () => _buildDropdownField(
            controller: null,
            label: 'Status',
            icon: Icons.info_outline,
            items: ['Active', 'Inactive', 'Draft'],
            value: ctrl.status.value,
            onChanged: (value) => ctrl.status.value = value ?? 'Draft',
            isRequired: true,
          ),
        ),
      ],
    );
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
        minLines: 1,
        maxLines: maxLines,
        decoration: InputDecoration(
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

  Widget _buildDropdownField({
    TextEditingController? controller,
    required String label,
    required IconData icon,
    required List<String> items,
    String? value,
    Function(String?)? onChanged,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value ?? (controller?.text.isEmpty ?? true ? null : controller!.text),
        decoration: InputDecoration(
          labelText: '$label${isRequired ? ' *' : ''}',
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
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged:
            onChanged ??
            (newValue) {
              if (controller != null && newValue != null) {
                controller.text = newValue;
              }
            },
      ),
    );
  }

  Widget _buildMultiSelectField({
    required TextEditingController txtController,
    required CandidateRequirementsCtrl ctrl,
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
                          children: items
                              .map(
                                (item) => Chip(
                                  label: Text(item, style: const TextStyle(fontSize: 12)),
                                  onDeleted: () => _removeItem(ctrl, fieldType, item),
                                  backgroundColor: Colors.blue[100],
                                  deleteIconColor: Colors.blue[700],
                                  labelStyle: TextStyle(color: Colors.blue[800]),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
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
                                  _addItem(ctrl, fieldType, txtController.text.trim());
                                  txtController.clear();
                                }
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _addItem(ctrl, fieldType, value.trim());
                              txtController.clear();
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

  RxList<String> _getFieldItems(CandidateRequirementsCtrl ctrl, String fieldType) {
    switch (fieldType) {
      case 'requiredSkills':
        return ctrl.requiredSkillsList;
      case 'preferredSkills':
        return ctrl.preferredSkillsList;
      case 'certification':
        return ctrl.certificationList;
      case 'educationQualification':
        return ctrl.educationQualificationList;
      case 'softSkills':
        return ctrl.softSkillsList;
      case 'techStack':
        return ctrl.techStackList;
      default:
        return <String>[].obs;
    }
  }

  void _addItem(CandidateRequirementsCtrl ctrl, String fieldType, String item) {
    switch (fieldType) {
      case 'requiredSkills':
        if (!ctrl.requiredSkillsList.contains(item)) {
          ctrl.requiredSkillsList.add(item);
        }
        break;
      case 'preferredSkills':
        if (!ctrl.preferredSkillsList.contains(item)) {
          ctrl.preferredSkillsList.add(item);
        }
        break;
      case 'certification':
        if (!ctrl.certificationList.contains(item)) {
          ctrl.certificationList.add(item);
        }
        break;
      case 'educationQualification':
        if (!ctrl.educationQualificationList.contains(item)) {
          ctrl.educationQualificationList.add(item);
        }
        break;
      case 'softSkills':
        if (!ctrl.softSkillsList.contains(item)) {
          ctrl.softSkillsList.add(item);
        }
        break;
      case 'techStack':
        if (!ctrl.techStackList.contains(item)) {
          ctrl.techStackList.add(item);
        }
        break;
    }
  }

  void _removeItem(CandidateRequirementsCtrl ctrl, String fieldType, String item) {
    switch (fieldType) {
      case 'requiredSkills':
        ctrl.requiredSkillsList.remove(item);
        break;
      case 'preferredSkills':
        ctrl.preferredSkillsList.remove(item);
        break;
      case 'certification':
        ctrl.certificationList.remove(item);
        break;
      case 'educationQualification':
        ctrl.educationQualificationList.remove(item);
        break;
      case 'softSkills':
        ctrl.softSkillsList.remove(item);
        break;
      case 'techStack':
        ctrl.techStackList.remove(item);
        break;
    }
  }

  Widget _buildBottomBar(BuildContext context, CandidateRequirementsCtrl ctrl) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
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
                onPressed: ctrl.isLoading.value
                    ? null
                    : () async {
                        await ctrl.createRequirement(candidateId: isEdit ? requirement!['_id'] : null);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: decoration.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: ctrl.isLoading.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        isEdit ? 'Update Requirement' : 'Create Requirement',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
