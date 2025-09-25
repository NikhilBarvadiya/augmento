import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_details/job_details_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class JobDetails extends StatelessWidget {
  final Map<String, dynamic>? job;
  final List? candidates;
  final String? type;
  final String? jobApplicationId;

  const JobDetails({super.key, this.job, this.candidates, this.type, this.jobApplicationId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JobDetailsCtrl());
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildJobHeader(job ?? {}),
            const SizedBox(height: 16),
            _buildJobDetailsCard(job ?? {}),
            const SizedBox(height: 16),
            if (type == 'available') _buildCandidateSelectionCard(controller) else _buildAppliedCandidatesCard(),
            const SizedBox(height: 24),
            _buildActionSection(context, controller, type ?? "", job?['_id'] ?? ""),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Job Details',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white),
      ),
      elevation: 0,
      centerTitle: true,
      backgroundColor: decoration.colorScheme.primary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
    );
  }

  Widget _buildJobHeader(Map<String, dynamic> job) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Icon(Icons.work_outline_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              job['jobTitle'] ?? 'Unknown Position',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(
                'Posted: ${job['createdAt'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(job['createdAt']).toLocal()) : 'N/A'}',
                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetailsCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Job Information', Icons.info_outline_rounded),
            const SizedBox(height: 16),
            _buildDetailGrid([
              _buildDetailItem('Type', job['jobType'], Icons.category_outlined),
              if (job['workType'] != null) _buildDetailItem('Work Type', job['workType'], Icons.work_outline_rounded),
              _buildDetailItem('Experience', job['experienceLevel'], Icons.trending_up_rounded),
              _buildDetailItem('Salary', '₹${job['minSalary'] ?? 'N/A'} - ₹${job['maxSalary'] ?? 'N/A'}', Icons.payments_outlined),
            ]),
            if (job['requiredSkills'] != null && (job['requiredSkills'] as List).isNotEmpty) ...[const SizedBox(height: 20), _buildSkillsSection('Required Skills', job['requiredSkills'], Colors.red)],
            if (job['preferredSkills'] != null && (job['preferredSkills'] as List).isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSkillsSection('Preferred Skills', job['preferredSkills'], Colors.blue),
            ],
            if (job['summary'] != null || job['jobDescription'] != null) ...[const SizedBox(height: 20), _buildDescriptionSection(job['summary'] ?? job['jobDescription'])],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: decoration.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: decoration.colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildDetailGrid(List<Widget> items) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: items[i]),
                if (i + 1 < items.length) ...[const SizedBox(width: 12), Expanded(child: items[i + 1])],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String? value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'N/A',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(String title, List<dynamic> skills, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                skill.toString(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color.withOpacity(.7)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(description, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
        ),
      ],
    );
  }

  Widget _buildCandidateSelectionCard(JobDetailsCtrl ctrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Select Candidates', Icons.people_outline_rounded),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search candidates...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
                ),
                onChanged: (value) => ctrl.searchQuery.value = value,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (ctrl.isLoading.value && ctrl.candidates.isEmpty) {
                return const Center(
                  child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
                );
              }
              if (ctrl.candidates.isEmpty) {
                return _buildEmptyState('No candidates found', Icons.person_search_rounded);
              }
              return Column(
                children: ctrl.candidates.map((candidate) {
                  return Obx(() => _buildCandidateCard(candidate, ctrl));
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate, JobDetailsCtrl ctrl) {
    final isSelected = ctrl.selectedCandidates.contains(candidate['_id']);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? decoration.colorScheme.primary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? decoration.colorScheme.primary.withOpacity(0.3) : Colors.grey[200]!, width: isSelected ? 2 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (isSelected) {
              ctrl.selectedCandidates.remove(candidate['_id']);
            } else {
              ctrl.selectedCandidates.add(candidate['_id']);
            }
            ctrl.update();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: isSelected ? decoration.colorScheme.primary.withOpacity(0.1) : Colors.grey[100], borderRadius: BorderRadius.circular(25)),
                  child: Icon(Icons.person_rounded, color: isSelected ? decoration.colorScheme.primary : Colors.grey[600], size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate['name'] ?? 'Unknown',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isSelected ? decoration.colorScheme.primary : Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${candidate['experience'] ?? 0} years experience',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      if (candidate['skills'] != null && (candidate['skills'] as List).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: (candidate['skills'] as List).take(3).map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                skill.toString(),
                                style: TextStyle(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.w500),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? decoration.colorScheme.primary : Colors.transparent,
                    border: Border.all(color: isSelected ? decoration.colorScheme.primary : Colors.grey[400]!, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppliedCandidatesCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Applied Candidates', Icons.group_rounded),
            const SizedBox(height: 16),
            if (candidates == null || candidates!.isEmpty)
              _buildEmptyState('No candidates have applied yet', Icons.person_off_rounded)
            else
              Column(
                children: candidates!.map((candidate) {
                  return _buildAppliedCandidateCard(candidate);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliedCandidateCard(Map<String, dynamic> candidate) {
    final candidateDetails = candidate['candidateDetails'] as Map<String, dynamic>? ?? {};
    final status = candidate['status'] ?? 'N/A';
    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey.withOpacity(0.1);
    IconData statusIcon = Icons.hourglass_empty_rounded;
    switch (status.toLowerCase()) {
      case 'selected':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.1);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'scheduled':
        statusColor = Colors.blue;
        statusBgColor = Colors.blue.withOpacity(0.1);
        statusIcon = Icons.schedule_rounded;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusBgColor = Colors.red.withOpacity(0.1);
        statusIcon = Icons.cancel_rounded;
        break;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(25)),
                  child: Icon(Icons.person_rounded, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidateDetails['name'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        candidateDetails['email'] != null && candidateDetails['email'].toString().isNotEmpty ? candidateDetails['email'] : 'No email provided',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (status.toLowerCase() == 'selected') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showOnboardingForm(Get.context!, candidate, job?['_id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: decoration.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Start Onboarding', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(40)),
            child: Icon(icon, size: 40, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, JobDetailsCtrl ctrl, String type, String? jobId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (type == 'available') ...[
            Expanded(
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: ctrl.selectedCandidates.isEmpty || jobId == null
                      ? null
                      : () {
                          ctrl.applyForJob(jobId);
                          Get.back();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: decoration.colorScheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    ctrl.selectedCandidates.isEmpty ? 'Apply' : 'Apply (${ctrl.selectedCandidates.length} selected)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                foregroundColor: decoration.colorScheme.primary,
                side: BorderSide(color: decoration.colorScheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Close', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _showOnboardingForm(BuildContext context, Map<String, dynamic> candidate, String? jobId) {
    final controller = Get.find<JobDetailsCtrl>();
    final formKey = GlobalKey<FormState>();
    final employeeName = TextEditingController(text: candidate['candidateDetails']?['name'] ?? '');
    final firstName = TextEditingController(text: candidate['candidateDetails']?['firstName'] ?? '');
    final lastName = TextEditingController(text: candidate['candidateDetails']?['lastName'] ?? '');
    final email = TextEditingController(text: candidate['candidateDetails']?['email'] ?? '');
    final workerMobileContactNumber = TextEditingController();
    final documentType = TextEditingController();
    final documentNumber = TextEditingController();
    final birthdate = TextEditingController();
    final physicalLocation = TextEditingController();
    final homeCity = TextEditingController();
    final homeState = TextEditingController();
    final homeZipCode = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.person_add_rounded, color: decoration.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Start Onboarding', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFormField(employeeName, 'Employee Name', Icons.person_rounded, true),
                  _buildFormField(firstName, 'First Name', Icons.person_outline_rounded, true),
                  _buildFormField(lastName, 'Last Name', Icons.person_outline_rounded, true),
                  _buildFormField(email, 'Email', Icons.email_rounded, true, isEmail: true),
                  _buildFormField(workerMobileContactNumber, 'Mobile Number', Icons.phone_rounded, true),
                  _buildFormField(documentType, 'Document Type', Icons.description_rounded, true),
                  _buildFormField(documentNumber, 'Document Number', Icons.numbers_rounded, true),
                  _buildFormField(birthdate, 'Birthdate (YYYY-MM-DD)', Icons.calendar_today_rounded, true, isDate: true),
                  _buildFormField(physicalLocation, 'Physical Location', Icons.location_on_rounded, true),
                  _buildFormField(homeCity, 'Home City', Icons.location_city_rounded, true),
                  _buildFormField(homeState, 'Home State', Icons.map_rounded, true),
                  _buildFormField(homeZipCode, 'Home Zip Code', Icons.local_post_office_rounded, true),
                  const SizedBox(height: 16),
                  _buildImageSection(controller),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Cancel'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600], padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                controller.startOnboarding(
                  candidateId: candidate['candidateId'],
                  jobApplicationId: jobApplicationId,
                  jobId: jobId,
                  employeeName: employeeName.text,
                  firstName: firstName.text,
                  lastName: lastName.text,
                  nonTmobileEmail: email.text,
                  workerMobileContactNumber: workerMobileContactNumber.text,
                  documentType: documentType.text,
                  documentNumber: documentNumber.text,
                  birthdate: birthdate.text,
                  physicalLocation: physicalLocation.text,
                  homeCity: homeCity.text,
                  homeState: homeState.text,
                  homeZipCode: homeZipCode.text,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: decoration.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(TextEditingController controller, String label, IconData icon, bool isRequired, {bool isEmail = false, bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          if (isEmail && value != null && value.isNotEmpty) {
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
          }
          return "";
          //   if (isDate && value != null && value.isNotEmpty) {
          //     if (!RegExp(r'^\d{4}-\d{2}-\d{2}).hasMatch(value)) {
          //         return 'Please use YYYY-MM-DD format';
          //     }
          //     }
          // return null;
        },
      ),
    );
  }

  Widget _buildImageSection(JobDetailsCtrl ctrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
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
                  color: ctrl.image.value != null ? decoration.colorScheme.primary.withOpacity(0.1) : Colors.grey[100],
                  border: Border.all(color: ctrl.image.value != null ? decoration.colorScheme.primary.withOpacity(0.3) : Colors.grey[300]!, width: 2),
                ),
                child: ctrl.image.value != null
                    ? ClipOval(child: Icon(Icons.person_rounded, size: 40, color: decoration.colorScheme.primary))
                    : Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.grey[600]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Profile Photo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text('Tap to upload image', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
