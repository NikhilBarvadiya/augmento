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
      appBar: AppBar(
        title: Text('Job Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        backgroundColor: decoration.colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(job ?? {}),
            _buildDetailsSection(job ?? {}),
            if (type == 'available') _buildCandidateSelection(controller) else _buildAppliedCandidates(),
            _buildActionButtons(context, controller, type ?? "", job?['_id'] ?? ""),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> job) {
    return Container(
      padding: EdgeInsets.all(16),
      color: decoration.colorScheme.primary.withOpacity(0.1),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: decoration.colorScheme.primary,
            child: Icon(Icons.work_outline, size: 30, color: decoration.colorScheme.onPrimary),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['jobTitle'] ?? 'Unknown',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: decoration.colorScheme.primary),
                ),
                SizedBox(height: 4),
                Text(
                  'Posted: ${job['createdAt'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(job['createdAt']).toLocal()) : 'N/A'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(Map<String, dynamic> job) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Job Details'),
          _buildDetailRow('Title', job['jobTitle']),
          _buildDetailRow('Type', job['jobType']),
          if (job['workType'] != null) _buildDetailRow('Work Type', job['workType'] ?? 'N/A'),
          _buildDetailRow('Salary', '${job['minSalary'] ?? 'N/A'} - ${job['maxSalary'] ?? 'N/A'}'),
          _buildDetailRow('Experience', job['experienceLevel']),
          _buildChipRow('Required Skills', job['requiredSkills']),
          _buildChipRow('Preferred Skills', job['preferredSkills']),
          _buildDetailRow('Summary', job['summary'] ?? job['jobDescription']),
          _buildDetailRow('Created At', job['createdAt'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(job['createdAt']).toLocal()) : 'N/A'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: decoration.colorScheme.primary),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A', style: TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow(String label, List<dynamic>? items) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: items == null || items.isEmpty
                ? Text('N/A', style: TextStyle(fontSize: 14, color: Colors.black87))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: items.map((item) {
                      return Chip(
                        label: Text(item.toString(), style: TextStyle(fontSize: 12, color: decoration.colorScheme.primary)),
                        backgroundColor: decoration.colorScheme.secondaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: decoration.colorScheme.primary.withOpacity(0.2)),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateSelection(JobDetailsCtrl ctrl) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Select Candidates'),
          TextField(
            decoration: InputDecoration(
              labelText: 'Search Candidates',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) => ctrl.searchQuery.value = value,
          ),
          SizedBox(height: 8),
          Obx(
            () => ctrl.isLoading.value && ctrl.candidates.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ctrl.candidates.isEmpty
                ? Text('No candidates found', style: TextStyle(fontSize: 14, color: Colors.grey))
                : SizedBox(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: ctrl.candidates.length,
                      itemBuilder: (context, index) {
                        final candidate = ctrl.candidates[index];
                        return Obx(
                          () => CheckboxListTile(
                            title: Text(candidate['name'] ?? 'Unknown', style: TextStyle(fontSize: 14)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [_buildChipRow('Skills', candidate['skills']), _buildDetailRow('Experience', '${candidate['experience'] ?? 0} years')],
                            ),
                            value: ctrl.selectedCandidates.contains(candidate['_id']),
                            onChanged: (value) {
                              if (value == true) {
                                ctrl.selectedCandidates.add(candidate['_id']);
                              } else {
                                ctrl.selectedCandidates.remove(candidate['_id']);
                              }
                              ctrl.update();
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedCandidates() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Applied Candidates'),
          candidates == null || candidates!.isEmpty
              ? Text('No candidates applied', style: TextStyle(fontSize: 14, color: Colors.grey))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: candidates!.length,
                  itemBuilder: (context, index) {
                    final candidate = candidates![index];
                    final candidateDetails = candidate['candidateDetails'] as Map<String, dynamic>? ?? {};
                    final status = candidate['status'] ?? 'N/A';
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                spacing: 2.0,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(candidateDetails['name'] ?? 'Unknown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                  Text('Email: ${candidateDetails['email'] != "" ? candidateDetails['email'] ?? 'No mention' : "No mention"}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Status: $status',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: status == 'Selected'
                                        ? Colors.green
                                        : status == 'Scheduled'
                                        ? Colors.blue
                                        : Colors.grey[600],
                                  ),
                                ),
                                if (status == 'Selected')
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _showOnboardingForm(context, candidate, job?['_id']);
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: decoration.colorScheme.primary, padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                      child: Text('Start Onboarding', style: TextStyle(fontSize: 12, color: decoration.colorScheme.onPrimary)),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, JobDetailsCtrl ctrl, String type, String? jobId) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (type == 'available')
            ElevatedButton(
              onPressed: ctrl.selectedCandidates.isEmpty || jobId == null
                  ? null
                  : () {
                      ctrl.applyForJob(jobId);
                      Get.back();
                    },
              style: ElevatedButton.styleFrom(backgroundColor: decoration.colorScheme.primary, disabledBackgroundColor: Colors.grey[300], padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              child: Text('Apply', style: TextStyle(fontSize: 14, color: decoration.colorScheme.onPrimary)),
            ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: decoration.colorScheme.secondary, padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            child: Text('Close', style: TextStyle(fontSize: 14, color: decoration.colorScheme.onSecondary)),
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
        title: Text('Start Onboarding', style: TextStyle(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: employeeName,
                  decoration: InputDecoration(labelText: 'Employee Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: firstName,
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: lastName,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: email,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) => value!.isEmpty || !value.contains('@') ? 'Valid email required' : null,
                ),
                TextFormField(
                  controller: workerMobileContactNumber,
                  decoration: InputDecoration(labelText: 'Mobile Number'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: documentType,
                  decoration: InputDecoration(labelText: 'Document Type'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: documentNumber,
                  decoration: InputDecoration(labelText: 'Document Number'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: birthdate,
                  decoration: InputDecoration(labelText: 'Birthdate (YYYY-MM-DD)'),
                  validator: (value) {
                    if (value!.isEmpty) return 'Required';
                    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return 'Invalid format';
                    return null;
                  },
                ),
                TextFormField(
                  controller: physicalLocation,
                  decoration: InputDecoration(labelText: 'Physical Location'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: homeCity,
                  decoration: InputDecoration(labelText: 'Home City'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: homeState,
                  decoration: InputDecoration(labelText: 'Home State'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: homeZipCode,
                  decoration: InputDecoration(labelText: 'Home Zip Code'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                _buildImageSection(controller),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: decoration.colorScheme.secondary)),
          ),
          ElevatedButton(
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
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: decoration.colorScheme.primary),
            child: Text('Submit', style: TextStyle(color: decoration.colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(JobDetailsCtrl ctrl) {
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
                child: ctrl.image.value != null ? ClipOval(child: Icon(Icons.person, size: 40, color: Colors.grey[600])) : Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
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
}
