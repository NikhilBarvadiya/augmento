import 'package:augmento/utils/decoration.dart';
import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:augmento/views/dashboard/tabs/job_management/ui/skill_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

class ProjectBid extends StatefulWidget {
  final Map<String, dynamic> project;

  const ProjectBid({super.key, required this.project});

  @override
  State<ProjectBid> createState() => _ProjectBidState();
}

class _ProjectBidState extends State<ProjectBid> {
  final _formKey = GlobalKey<FormState>();
  final _bidController = TextEditingController();
  final _coverLetterController = TextEditingController();
  final _customStartDateController = TextEditingController();
  final _customEndDateController = TextEditingController();

  String selectedDuration = '';
  List<PlatformFile> supportingDocs = [];
  bool isLoading = false;
  DateTime? customStartDate, customEndDate;

  final List<DurationOption> durationOptions = [
    DurationOption('3-6 months', '3 to 6', Icons.schedule),
    DurationOption('6-12 months', '6 to 12', Icons.event),
    DurationOption('More than 12 months', '12+', Icons.timeline_rounded),
    DurationOption('Custom Duration', 'custom', Icons.date_range),
  ];

  @override
  void dispose() {
    _bidController.dispose();
    _coverLetterController.dispose();
    _customStartDateController.dispose();
    _customEndDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildProjectOverview(), const SizedBox(height: 24), _buildProposalSection()]),
                  ),
                ),
              ),
              if (!isKeyboardVisible) _buildBottomSection(),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Submit Proposal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: decoration.colorScheme.primary,
      foregroundColor: decoration.colorScheme.onPrimary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.close(1),
        ),
      ),
    );
  }

  Widget _buildProjectOverview() {
    final requiredSkills = widget.project['skills'] as List? ?? [];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.work_outline, color: decoration.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project['title']?.toString().capitalizeFirst ?? 'Unknown Project',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.project['scope']?.toString().capitalizeFirst} • ${widget.project['experienceLevel']?.toString().capitalizeFirst}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.project['description']?.toString().capitalizeFirst ?? 'Unknown description'),
          const SizedBox(height: 16),
          SkillSection(candidate: widget.project),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.code_rounded, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Skills',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          requiredSkills.isNotEmpty
              ? Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: requiredSkills.take(4).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple[200]!),
                      ),
                      child: Text(
                        skill.toString(),
                        style: TextStyle(fontSize: 11, color: Colors.purple[700], fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Text('No skills specified', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ),
        ],
      ),
    );
  }

  Widget _buildProposalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Your Proposal Details', Icons.description),
          const SizedBox(height: 20),
          _buildBidAmountField(),
          const SizedBox(height: 24),
          _buildTimelineSection(),
          const SizedBox(height: 24),
          _buildCoverLetterField(),
          const SizedBox(height: 24),
          _buildSupportingDocsSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: decoration.colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildBidAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bid Amount *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bidController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter your bid amount',
            prefixIcon: Icon(Icons.currency_rupee, color: Colors.grey[600]),
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
              borderSide: BorderSide(color: decoration.colorScheme.primary),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your bid amount';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Timeline *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        ...durationOptions.map((option) => _buildDurationOption(option)),
        if (selectedDuration == 'custom') ...[const SizedBox(height: 16), _buildCustomDateRange()],
      ],
    );
  }

  Widget _buildDurationOption(DurationOption option) {
    final isSelected = selectedDuration == option.value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDuration = option.value;
          if (option.value != 'custom') {
            customStartDate = null;
            customEndDate = null;
            _customStartDateController.clear();
            _customEndDateController.clear();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? decoration.colorScheme.primary.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? decoration.colorScheme.primary : Colors.grey[300]!, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(option.icon, color: isSelected ? decoration.colorScheme.primary : Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Text(
              option.label,
              style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? decoration.colorScheme.primary : Colors.grey[700]),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: decoration.colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDateRange() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customStartDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Date *',
                    hintText: 'Select start date',
                    prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onTap: () => _selectDate(true),
                  validator: selectedDuration == 'custom'
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select start date';
                          }
                          return null;
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _customEndDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'End Date *',
                    hintText: 'Select end date',
                    prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onTap: () => _selectDate(false),
                  validator: selectedDuration == 'custom'
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select end date';
                          }
                          return null;
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoverLetterField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cover Letter *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _coverLetterController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Tell the client why you\'re the perfect fit for this project...',
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
              borderSide: BorderSide(color: decoration.colorScheme.primary),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please write a cover letter';
            }
            if (value.length < 50) {
              return 'Cover letter should be at least 50 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSupportingDocsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Supporting Documents',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text('Upload relevant documents to strengthen your proposal (Optional)', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickSupportingDocs,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, color: decoration.colorScheme.primary, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload documents',
                    style: TextStyle(color: decoration.colorScheme.primary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (supportingDocs.isNotEmpty) ...[const SizedBox(height: 12), ...supportingDocs.map((file) => _buildFileItem(file))],
      ],
    );
  }

  Widget _buildFileItem(PlatformFile file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, color: Colors.blue[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              file.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                supportingDocs.remove(file);
              });
            },
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitProposal,
            style: ElevatedButton.styleFrom(
              backgroundColor: decoration.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : const Text('Submit Proposal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(primary: decoration.colorScheme.primary)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          customStartDate = picked;
          _customStartDateController.text = "${picked.day}/${picked.month}/${picked.year}";
        } else {
          if (customStartDate != null && picked.isBefore(customStartDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End date cannot be before start date')));
            return;
          }
          customEndDate = picked;
          _customEndDateController.text = "${picked.day}/${picked.month}/${picked.year}";
        }
      });
    }
  }

  Future<void> _pickSupportingDocs() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png']);
      if (result != null) {
        setState(() {
          supportingDocs.addAll(result.files);
        });
      }
    } catch (e) {
      toaster.error('Error picking files: $e');
    }
  }

  Future<void> _submitProposal() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDuration.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a project timeline')));
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final Map<String, dynamic> requestData = {
        'projectId': widget.project['_id'],
        'bidAmount': _bidController.text,
        'coverLetter': _coverLetterController.text,
        'duration': selectedDuration == 'custom' ? 'custom' : selectedDuration,
      };
      if (selectedDuration == 'custom') {
        requestData['startDate'] = customStartDate?.toIso8601String();
        requestData['endDate'] = customEndDate?.toIso8601String();
      }
      Map<String, dynamic> response = await Get.find<AuthService>().bidOnProject(requestData, supportingDocs);
      if (response.isNotEmpty) {
        Get.close(1);
      }
    } catch (e) {
      toaster.error(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

class DurationOption {
  final String label;
  final String value;
  final IconData icon;

  DurationOption(this.label, this.value, this.icon);
}
