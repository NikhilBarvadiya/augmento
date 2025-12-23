import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/candidate_requirements/candidate_requirements_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class RequirementForm extends StatefulWidget {
  final Map<String, dynamic>? requirement;
  final bool isEdit;

  const RequirementForm({super.key, this.requirement, this.isEdit = false});

  @override
  State<RequirementForm> createState() => _RequirementFormState();
}

class _RequirementFormState extends State<RequirementForm> {
  final PageController _pageController = PageController();
  final RxInt _currentStep = 0.obs;
  final int _totalSteps = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep(CandidateRequirementsCtrl ctrl) {
    if (_currentStep.value < _totalSteps - 1) {
      _currentStep.value++;
      _pageController.jumpToPage(_currentStep.value);
    }
  }

  void _previousStep() {
    if (_currentStep.value > 0) {
      _currentStep.value--;
      _pageController.jumpToPage(_currentStep.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CandidateRequirementsCtrl>(
      builder: (ctrl) {
        if (widget.isEdit && widget.requirement != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ctrl.populateForm(widget.requirement!);
          });
        }
        return KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return Scaffold(
              backgroundColor: decoration.colorScheme.surfaceContainerLowest,
              appBar: _buildAppBar(),
              body: Column(
                children: [
                  _buildProgressIndicator(),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) => _currentStep.value = index,
                      children: [_buildStep1BasicInfo(ctrl), _buildStep2Skills(ctrl), _buildStep3JobDetails(ctrl), _buildStep4Salary(ctrl), _buildStep5Review(ctrl)],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: !isKeyboardVisible ? _buildNavigationButtons(context, ctrl) : const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.isEdit ? 'Edit Job Requirement' : 'Add Job Requirement', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: decoration.colorScheme.primary,
      foregroundColor: decoration.colorScheme.onPrimary,
      automaticallyImplyLeading: false,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => _showExitDialog(),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Obx(() {
            return Row(
              children: List.generate(_totalSteps, (index) {
                final isCompleted = index < _currentStep.value;
                final isCurrent = index == _currentStep.value;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: isCompleted || isCurrent ? decoration.colorScheme.primary : decoration.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (index < _totalSteps - 1) const SizedBox(width: 4),
                    ],
                  ),
                );
              }),
            );
          }),
          const SizedBox(height: 12),
          Obx(() {
            final stepNames = ['Basic Info', 'Skills', 'Job Details', 'Salary', 'Review'];
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${_currentStep.value + 1} of $_totalSteps',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: decoration.colorScheme.primary),
                ),
                Text(
                  stepNames[_currentStep.value],
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: decoration.colorScheme.onSurfaceVariant),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStep1BasicInfo(CandidateRequirementsCtrl ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(icon: Icons.info_rounded, title: 'Basic Information', subtitle: 'Let\'s start with the basics'),
          const SizedBox(height: 24),
          _buildFormField(controller: ctrl.jobTitleCtrl, label: 'Job Title', icon: Icons.work_rounded, hint: 'e.g., Senior Flutter Developer', isRequired: true),
          _buildDropdownField(controller: ctrl.jobTypeCtrl, label: 'Job Type', icon: Icons.schedule_rounded, items: ['Full-time', 'Part-time', 'Contract', 'Internship'], isRequired: true),
          _buildDropdownField(controller: ctrl.workTypeCtrl, label: 'Work Type', icon: Icons.laptop_rounded, items: ['Remote', 'Hybrid', 'On-site'], isRequired: true),
          _buildDropdownField(controller: ctrl.experienceLevelCtrl, label: 'Experience Level', icon: Icons.trending_up_rounded, items: ['Entry', 'Mid', 'Senior', 'Lead'], isRequired: true),
          _buildFormField(controller: ctrl.locationCtrl, label: 'Location', icon: Icons.location_on_rounded, hint: 'e.g., Remote, New York, Hybrid', isRequired: true),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStep2Skills(CandidateRequirementsCtrl ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(icon: Icons.psychology_rounded, title: 'Skills & Qualifications', subtitle: 'What skills are you looking for?'),
          const SizedBox(height: 24),
          _buildMultiSelectField(
            txtController: ctrl.requiredSkillsCtrl,
            ctrl: ctrl,
            fieldType: 'requiredSkills',
            label: 'Required Skills',
            icon: Icons.star_rounded,
            hint: 'Add required skills',
            isRequired: true,
          ),
          _buildMultiSelectField(
            txtController: ctrl.preferredSkillsCtrl,
            ctrl: ctrl,
            fieldType: 'preferredSkills',
            label: 'Preferred Skills',
            icon: Icons.star_border_rounded,
            hint: 'Add preferred skills',
          ),
          _buildMultiSelectField(
            txtController: ctrl.educationQualificationCtrl,
            ctrl: ctrl,
            fieldType: 'educationQualification',
            label: 'Education Qualifications',
            icon: Icons.school_rounded,
            hint: 'Add education qualifications',
            isRequired: true,
          ),
          _buildMultiSelectField(txtController: ctrl.certificationCtrl, ctrl: ctrl, fieldType: 'certification', label: 'Certifications', icon: Icons.verified_rounded, hint: 'Add certifications'),
          _buildMultiSelectField(txtController: ctrl.softSkillsCtrl, ctrl: ctrl, fieldType: 'softSkills', label: 'Soft Skills', icon: Icons.people_rounded, hint: 'Add soft skills', isRequired: true),
          _buildMultiSelectField(txtController: ctrl.techStackCtrl, ctrl: ctrl, fieldType: 'techStack', label: 'Tech Stack', icon: Icons.code_rounded, hint: 'Add tech stack'),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStep3JobDetails(CandidateRequirementsCtrl ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(icon: Icons.description_rounded, title: 'Job Details', subtitle: 'Describe the role'),
          const SizedBox(height: 24),
          _buildFormField(controller: ctrl.summaryCtrl, label: 'Job Summary', icon: Icons.summarize_rounded, hint: 'Brief overview of the position', maxLines: 4, isRequired: true),
          _buildFormField(controller: ctrl.responsibilityCtrl, label: 'Key Responsibilities', icon: Icons.task_alt_rounded, hint: 'Main duties and responsibilities', maxLines: 6, isRequired: true),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStep4Salary(CandidateRequirementsCtrl ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(icon: Icons.monetization_on_rounded, title: 'Salary Information', subtitle: 'Set the compensation range'),
          const SizedBox(height: 24),
          _buildDropdownField(controller: ctrl.salaryCurrencyCtrl, label: 'Currency', icon: Icons.currency_exchange_rounded, items: ['USD', 'EUR', 'GBP', 'INR'], isRequired: true),
          Row(
            children: [
              Expanded(
                child: _buildFormField(controller: ctrl.salaryMinCtrl, label: 'Minimum Salary', icon: Icons.attach_money_rounded, keyboardType: TextInputType.numberWithOptions(signed: true), hint: '50000', isRequired: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(controller: ctrl.salaryMaxCtrl, label: 'Maximum Salary', icon: Icons.attach_money_rounded, keyboardType: TextInputType.numberWithOptions(signed: true), hint: '80000', isRequired: true),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: decoration.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: decoration.colorScheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_rounded, color: decoration.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Competitive salary ranges attract better candidates', style: TextStyle(fontSize: 13, color: decoration.colorScheme.onSurface)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStep5Review(CandidateRequirementsCtrl ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(icon: Icons.check_circle_rounded, title: 'Review & Publish', subtitle: 'Review your job requirement'),
          const SizedBox(height: 24),
          Obx(
            () => _buildDropdownField(
              controller: null,
              label: 'Status',
              icon: Icons.settings_rounded,
              items: ['Active', 'Inactive', 'Draft'],
              value: ctrl.status.value,
              onChanged: (value) => ctrl.status.value = value ?? 'Draft',
              isRequired: true,
            ),
          ),
          _buildReviewSection(ctrl),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildReviewSection(CandidateRequirementsCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: decoration.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewItem('Job Title', ctrl.jobTitleCtrl.text.isEmpty ? 'Not specified' : ctrl.jobTitleCtrl.text, Icons.work_rounded),
          _buildReviewDivider(),
          _buildReviewItem('Job Type', ctrl.jobTypeCtrl.text.isEmpty ? 'Not specified' : ctrl.jobTypeCtrl.text, Icons.schedule_rounded),
          _buildReviewDivider(),
          _buildReviewItem('Work Type', ctrl.workTypeCtrl.text.isEmpty ? 'Not specified' : ctrl.workTypeCtrl.text, Icons.laptop_rounded),
          _buildReviewDivider(),
          _buildReviewItem('Location', ctrl.locationCtrl.text.isEmpty ? 'Not specified' : ctrl.locationCtrl.text, Icons.location_on_rounded),
          _buildReviewDivider(),
          Obx(() => _buildReviewItem('Required Skills', ctrl.requiredSkillsList.isEmpty ? 'None added' : ctrl.requiredSkillsList.join(', '), Icons.star_rounded)),
          _buildReviewDivider(),
          _buildReviewItem(
            'Salary Range',
            ctrl.salaryMinCtrl.text.isEmpty || ctrl.salaryMaxCtrl.text.isEmpty ? 'Not specified' : '${ctrl.salaryCurrencyCtrl.text} ${ctrl.salaryMinCtrl.text} - ${ctrl.salaryMaxCtrl.text}',
            Icons.monetization_on_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: decoration.colorScheme.primaryContainer.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: decoration.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: decoration.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: decoration.colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewDivider() {
    return Divider(height: 24, color: decoration.colorScheme.outline.withOpacity(0.2));
  }

  Widget _buildStepHeader({required IconData icon, required String title, required String subtitle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Icon(icon, size: 28, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: decoration.colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 14, color: decoration.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
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
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        minLines: 1,
        maxLines: maxLines,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: '$label${isRequired ? ' *' : ''}',
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
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
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(color: decoration.colorScheme.onSurfaceVariant),
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
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: value ?? (controller?.text.isEmpty ?? true ? null : controller!.text),
        decoration: InputDecoration(
          labelText: '$label${isRequired ? ' *' : ''}',
          prefixIcon: Icon(icon, size: 20),
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
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(color: decoration.colorScheme.onSurfaceVariant),
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
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label${isRequired ? ' *' : ''}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: decoration.colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: decoration.colorScheme.outline.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (items.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: items
                          .map(
                            (item) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: decoration.colorScheme.primaryContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: decoration.colorScheme.primary.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: decoration.colorScheme.primary),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _removeItem(ctrl, fieldType, item),
                                    child: Icon(Icons.close_rounded, size: 16, color: decoration.colorScheme.primary),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: txtController,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(fontSize: 14, color: decoration.colorScheme.onSurfaceVariant),
                      border: InputBorder.none,
                      prefixIcon: Icon(icon, size: 20),
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (txtController.text.trim().isNotEmpty) {
                            _addItem(ctrl, fieldType, txtController.text.trim());
                            txtController.clear();
                          }
                        },
                        icon: Icon(Icons.add_circle_rounded, color: decoration.colorScheme.primary),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _addItem(ctrl, fieldType, value.trim());
                        txtController.clear();
                      }
                    },
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
    final items = _getFieldItems(ctrl, fieldType);
    if (!items.contains(item)) {
      items.add(item);
    }
  }

  void _removeItem(CandidateRequirementsCtrl ctrl, String fieldType, String item) {
    final items = _getFieldItems(ctrl, fieldType);
    items.remove(item);
  }

  Widget _buildNavigationButtons(BuildContext context, CandidateRequirementsCtrl ctrl) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: Obx(() {
          final isFirstStep = _currentStep.value == 0;
          final isLastStep = _currentStep.value == _totalSteps - 1;

          return Row(
            children: [
              if (!isFirstStep)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previousStep,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: decoration.colorScheme.outline),
                    ),
                  ),
                ),
              if (!isFirstStep) const SizedBox(width: 12),
              Expanded(
                flex: isFirstStep ? 1 : 2,
                child: ElevatedButton(
                  onPressed: ctrl.isLoading.value
                      ? null
                      : () async {
                          if (isLastStep) {
                            await ctrl.createRequirement(candidateId: widget.isEdit ? widget.requirement!['_id'] : null);
                          } else {
                            _nextStep(ctrl);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: decoration.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: ctrl.isLoading.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(isLastStep ? (widget.isEdit ? 'Update' : 'Create') : 'Next', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            if (!isLastStep) ...[const SizedBox(width: 8), const Icon(Icons.arrow_forward_rounded, size: 18)],
                          ],
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showExitDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.warning_rounded, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Exit Form?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Are you sure you want to exit? All unsaved changes will be lost.', style: TextStyle(fontSize: 15)),
        actions: [
          TextButton(onPressed: () => Get.close(1), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.close(2),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
