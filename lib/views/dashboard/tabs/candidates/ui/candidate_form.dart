import 'package:augmento/utils/decoration.dart';
import 'package:augmento/utils/network/api_config.dart';
import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/dashboard/tabs/candidates/candidates_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class CandidateForm extends StatefulWidget {
  final Map<String, dynamic>? candidate;
  final bool isEdit;

  const CandidateForm({super.key, this.candidate, this.isEdit = false});

  @override
  State<CandidateForm> createState() => _CandidateFormState();
}

class _CandidateFormState extends State<CandidateForm> {
  final PageController _pageController = PageController();
  final RxInt _currentStep = 0.obs;
  final int _totalSteps = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep(CandidatesCtrl ctrl) {
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
    return GetBuilder<CandidatesCtrl>(
      builder: (ctrl) {
        if (widget.isEdit && widget.candidate != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _populateForm(ctrl);
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
                      children: [_buildStep1Profile(ctrl), _buildStep2PersonalInfo(ctrl), _buildStep3Professional(ctrl), _buildStep4Documents(ctrl)],
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
      title: Text(widget.isEdit ? 'Edit Candidate' : 'Add Candidate', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: decoration.colorScheme.primary,
      foregroundColor: Colors.white,
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
            final stepNames = ['Profile', 'Personal', 'Professional', 'Documents'];
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

  Widget _buildStep1Profile(CandidatesCtrl ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(icon: Icons.person_rounded, title: 'Profile Setup', subtitle: 'Upload photo and basic details'),
          const SizedBox(height: 32),
          Center(
            child: Obx(
              () => GestureDetector(
                onTap: () => ctrl.pickFile('profileImage'),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: decoration.colorScheme.primaryContainer.withOpacity(0.3),
                    border: Border.all(color: decoration.colorScheme.primary.withOpacity(0.5), width: 3),
                    boxShadow: [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: ctrl.profileImage.value != null
                      ? ClipOval(child: Icon(Icons.person, size: 60, color: decoration.colorScheme.primary))
                      : widget.isEdit && widget.candidate?['profileImage'] != null
                      ? ClipOval(
                          child: Image.network(
                            '${APIConfig.resourceBaseURL}/${widget.candidate!['profileImage']}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 60, color: decoration.colorScheme.primary),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, size: 48, color: decoration.colorScheme.primary),
                            const SizedBox(height: 8),
                            Text(
                              'Upload Photo',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: decoration.colorScheme.primary),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildFormField(controller: ctrl.nameCtrl, label: 'Full Name', icon: Icons.person_rounded, hint: 'Enter candidate full name', isRequired: true),
          _buildFormField(
            controller: ctrl.mobileCtrl,
            label: 'Mobile Number',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.numberWithOptions(signed: true),
            hint: '10 digit number',
            isRequired: true,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStep2PersonalInfo(CandidatesCtrl ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(icon: Icons.contact_page_rounded, title: 'Personal Information', subtitle: 'Contact and education details'),
          const SizedBox(height: 24),
          _buildMultiSelectField(txtController: ctrl.educationCtrl, ctrl: ctrl, fieldType: 'education', label: 'Education', icon: Icons.school_rounded, hint: 'Add education qualifications'),
          _buildFormField(controller: ctrl.currentSalaryCtrl, label: 'Current Salary', icon: Icons.attach_money_rounded, keyboardType: TextInputType.numberWithOptions(signed: true), hint: 'Monthly'),
          _buildFormField(controller: ctrl.chargesCtrl, label: 'Expected Salary', icon: Icons.price_change_rounded, keyboardType: TextInputType.numberWithOptions(signed: true), hint: 'Monthly'),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStep3Professional(CandidatesCtrl ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(icon: Icons.work_rounded, title: 'Professional Info', subtitle: 'Skills, experience and availability'),
          const SizedBox(height: 24),
          _buildMultiSelectField(txtController: ctrl.skillsCtrl, ctrl: ctrl, fieldType: 'skills', label: 'Skills', icon: Icons.code_rounded, hint: 'Add technical skills', isRequired: true),
          _buildMultiSelectField(txtController: ctrl.techStackCtrl, ctrl: ctrl, fieldType: 'techStack', label: 'Tech Stack', icon: Icons.computer_rounded, hint: 'Add technology stack'),
          _buildFormField(
            controller: ctrl.experienceCtrl,
            label: 'Experience (Years)',
            icon: Icons.timeline_rounded,
            keyboardType: TextInputType.numberWithOptions(signed: true),
            hint: 'e.g., 3',
            isRequired: true,
          ),
          _buildAvailabilityDropdown(ctrl),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStep4Documents(CandidatesCtrl ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(icon: Icons.description_rounded, title: 'Documents & Status', subtitle: 'Upload resume and set status'),
          const SizedBox(height: 24),
          Obx(
            () => _buildFileUploadCard(
              title: 'Resume',
              subtitle: 'Upload candidate resume (PDF preferred)',
              fileName: ctrl.resume.value?.name,
              icon: Icons.description_rounded,
              onTap: () => ctrl.pickFile('resume'),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: decoration.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: decoration.colorScheme.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: decoration.colorScheme.onSurface),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ctrl.isCandidate.value ? decoration.colorScheme.primary.withOpacity(0.3) : decoration.colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: SwitchListTile(
                      title: const Text('IT Futurz Candidate', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Mark as internal candidate'),
                      value: ctrl.isCandidate.value,
                      onChanged: (value) => ctrl.isCandidate.value = value,
                      activeColor: decoration.colorScheme.primary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: ctrl.candidateStatus.value,
                    decoration: InputDecoration(
                      labelText: 'Availability Status',
                      prefixIcon: Icon(Icons.info_rounded, color: decoration.colorScheme.primary),
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
                    ),
                    items: ['Available', 'Not Available'].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                    onChanged: (value) => ctrl.candidateStatus.value = value ?? 'Available',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
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
        maxLines: maxLines,
        textInputAction: TextInputAction.done,
        maxLength: keyboardType == TextInputType.numberWithOptions(signed: true) ? 10 : null,
        decoration: InputDecoration(
          counterText: "",
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

  Widget _buildAvailabilityDropdown(CandidatesCtrl ctrl) {
    return DropdownButtonFormField<String>(
      value: ctrl.availabilityCtrl.text.isEmpty ? null : ctrl.availabilityCtrl.text,
      decoration: InputDecoration(
        labelText: 'Availability',
        prefixIcon: const Icon(Icons.schedule_rounded, size: 20),
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
      ),
      items: ['Immediate', '1 Week', '2 Weeks', '1 Month', 'Other'].map((availability) => DropdownMenuItem(value: availability, child: Text(availability))).toList(),
      onChanged: (value) {
        ctrl.availabilityCtrl.text = value ?? '';
      },
      hint: const Text('Select'),
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
    final items = _getFieldItems(ctrl, fieldType);
    if (!items.contains(item)) {
      items.add(item);
    }
  }

  void _removeItem(CandidatesCtrl ctrl, String fieldType, String item) {
    final items = _getFieldItems(ctrl, fieldType);
    items.remove(item);
  }

  Widget _buildFileUploadCard({required String title, required String subtitle, String? fileName, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: fileName != null ? Colors.green.withOpacity(0.5) : decoration.colorScheme.outline.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(16),
          color: fileName != null ? Colors.green.withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: fileName != null ? Colors.green.withOpacity(0.2) : decoration.colorScheme.primaryContainer.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: fileName != null ? Colors.green[700] : decoration.colorScheme.primary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName ?? title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: fileName != null ? Colors.green[800] : decoration.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileName != null ? 'File selected successfully' : subtitle,
                    style: TextStyle(fontSize: 13, color: fileName != null ? Colors.green[600] : decoration.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(fileName != null ? Icons.check_circle_rounded : Icons.upload_file_rounded, color: fileName != null ? Colors.green[600] : decoration.colorScheme.primary, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, CandidatesCtrl ctrl) {
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
                            if (_validateForm(ctrl)) {
                              if (widget.isEdit) {
                                ctrl.createCandidate(candidateId: widget.candidate!['_id']);
                              } else {
                                ctrl.createCandidate();
                              }
                            }
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

  void _populateForm(CandidatesCtrl ctrl) {
    if (widget.candidate == null) return;
    ctrl.nameCtrl.text = widget.candidate!['name'] ?? '';
    ctrl.mobileCtrl.text = widget.candidate!['mobile'] ?? '';
    ctrl.experienceCtrl.text = widget.candidate!['experience']?.toString() ?? '';
    ctrl.availabilityCtrl.text = widget.candidate!['availability'] ?? '';
    ctrl.chargesCtrl.text = widget.candidate!['charges']?.toString() ?? '';
    ctrl.currentSalaryCtrl.text = widget.candidate!['currentSalary']?.toString() ?? '';
    ctrl.isCandidate.value = widget.candidate!['itfuturzCandidate'] ?? false;
    ctrl.candidateStatus.value = widget.candidate!['status'] ?? 'Available';
    if (widget.candidate!['skills'] != null) {
      ctrl.skillsList.value = List<String>.from(widget.candidate!['skills']);
    }
    if (widget.candidate!['techStack'] != null) {
      ctrl.techStackList.value = List<String>.from(widget.candidate!['techStack']);
    }
    if (widget.candidate!['education'] != null) {
      ctrl.educationList.value = List<String>.from(widget.candidate!['education']);
    }
  }

  bool _validateForm(CandidatesCtrl ctrl) {
    if (ctrl.nameCtrl.text.trim().isEmpty) {
      toaster.warning('Please enter candidate name');
      return false;
    }
    if (ctrl.mobileCtrl.text.trim().isEmpty) {
      toaster.warning('Please enter mobile number');
      return false;
    }
    if (ctrl.skillsList.isEmpty) {
      toaster.warning('Please add at least one skill');
      return false;
    }
    return true;
  }
}
