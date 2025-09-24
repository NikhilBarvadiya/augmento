import 'package:augmento/utils/decoration.dart';
import 'package:augmento/utils/network/api_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'candidates_ctrl.dart';

class Candidates extends StatelessWidget {
  const Candidates({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CandidatesCtrl>(
      init: CandidatesCtrl(),
      builder: (ctrl) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Candidates Management'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: decoration.colorScheme.primary,
            foregroundColor: decoration.colorScheme.onPrimary,
          ),
          body: RefreshIndicator(
            onRefresh: () => ctrl.fetchCandidates(reset: true),
            child: Obx(
              () => ctrl.isLoading.value && ctrl.candidates.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Search',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onChanged: (value) => ctrl.searchQuery.value = value,
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.filter_list),
                                onSelected: (value) => ctrl.statusFilter.value = value,
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: '', child: Text('All Statuses')),
                                  const PopupMenuItem(value: 'Available', child: Text('Available')),
                                  const PopupMenuItem(value: 'Not Available', child: Text('Not Available')),
                                ],
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.calendar_today),
                                onSelected: (value) => ctrl.availabilityFilter.value = value,
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: '', child: Text('All Availabilities')),
                                  const PopupMenuItem(value: 'Immediate', child: Text('Immediate')),
                                  const PopupMenuItem(value: '1 Week', child: Text('1 Week')),
                                  const PopupMenuItem(value: '2 Weeks', child: Text('2 Weeks')),
                                  const PopupMenuItem(value: '1 Month', child: Text('1 Month')),
                                  const PopupMenuItem(value: 'Other', child: Text('Other')),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: ctrl.candidates.length + (ctrl.hasMore.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == ctrl.candidates.length) {
                                ctrl.fetchCandidates();
                                return const Center(child: CircularProgressIndicator());
                              }
                              final candidate = ctrl.candidates[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: candidate['profileImage'] != null ? NetworkImage('${APIConfig.resourceBaseURL}/${candidate['profileImage']}') : null,
                                    child: candidate['profileImage'] == null ? const Icon(Icons.person) : null,
                                  ),
                                  title: Text(candidate['name'] ?? 'Unknown'),
                                  subtitle: Text(
                                    'Skills: ${candidate['skills']?.join(', ') ?? 'N/A'}\n'
                                    'Status: ${candidate['status'] ?? 'N/A'}',
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditDialog(context, ctrl, candidate);
                                      } else if (value == 'delete') {
                                        ctrl.deleteCandidates([candidate['_id']]);
                                      } else if (value == 'status') {
                                        ctrl.changeCandidateStatus(candidate['_id'], candidate['status'] == 'Available' ? 'Not Available' : 'Available');
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                      PopupMenuItem(value: 'status', child: Text('Toggle Status (${candidate['status'] == 'Available' ? 'Not Available' : 'Available'})')),
                                    ],
                                  ),
                                  onTap: () => _showDetailsDialog(context, candidate),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          floatingActionButton: FloatingActionButton(onPressed: () => _showCreateDialog(context, ctrl), child: const Icon(Icons.add)),
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context, CandidatesCtrl ctrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Candidate'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl.nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: ctrl.mobileCtrl,
                decoration: const InputDecoration(labelText: 'Mobile'),
              ),
              TextField(
                controller: ctrl.skillsCtrl,
                decoration: const InputDecoration(labelText: 'Skills (comma-separated)'),
              ),
              TextField(
                controller: ctrl.techStackCtrl,
                decoration: const InputDecoration(labelText: 'Tech Stack (comma-separated)'),
              ),
              TextField(
                controller: ctrl.educationCtrl,
                decoration: const InputDecoration(labelText: 'Education (comma-separated)'),
              ),
              TextField(
                controller: ctrl.experienceCtrl,
                decoration: const InputDecoration(labelText: 'Experience (years)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ctrl.availabilityCtrl,
                decoration: const InputDecoration(labelText: 'Availability'),
              ),
              TextField(
                controller: ctrl.chargesCtrl,
                decoration: const InputDecoration(labelText: 'Charges'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ctrl.currentSalaryCtrl,
                decoration: const InputDecoration(labelText: 'Current Salary'),
                keyboardType: TextInputType.number,
              ),
              Obx(() => CheckboxListTile(title: const Text('IT Futurz Candidate'), value: ctrl.isCandidate.value, onChanged: (value) => ctrl.isCandidate.value = value ?? false)),
              Obx(
                () => DropdownButton<String>(
                  value: ctrl.candidateStatus.value,
                  items: ['Available', 'Not Available'].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                  onChanged: (value) => ctrl.candidateStatus.value = value ?? 'Available',
                  hint: const Text('Status'),
                ),
              ),
              ListTile(title: Text(ctrl.profileImage.value?.name ?? 'Select Profile Image'), trailing: const Icon(Icons.upload), onTap: () => ctrl.pickFile('profileImage')),
              ListTile(title: Text(ctrl.resume.value?.name ?? 'Select Resume'), trailing: const Icon(Icons.upload), onTap: () => ctrl.pickFile('resume')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ctrl.createCandidate();
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, CandidatesCtrl ctrl, Map<String, dynamic> candidate) {
    ctrl.nameCtrl.text = candidate['name'] ?? '';
    ctrl.mobileCtrl.text = candidate['mobile'] ?? '';
    ctrl.skillsCtrl.text = candidate['skills']?.join(', ') ?? '';
    ctrl.techStackCtrl.text = candidate['techStack']?.join(', ') ?? '';
    ctrl.educationCtrl.text = candidate['education']?.join(', ') ?? '';
    ctrl.experienceCtrl.text = candidate['experience']?.toString() ?? '';
    ctrl.availabilityCtrl.text = candidate['availability'] ?? '';
    ctrl.chargesCtrl.text = candidate['charges']?.toString() ?? '';
    ctrl.currentSalaryCtrl.text = candidate['currentSalary']?.toString() ?? '';
    ctrl.isCandidate.value = candidate['itfuturzCandidate'] ?? false;
    ctrl.candidateStatus.value = candidate['status'] ?? 'Available';
    ctrl.profileImage.value = null;
    ctrl.resume.value = null;
    ctrl.aadhaarCard.value = null;
    ctrl.panCard.value = null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Candidate'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl.nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: ctrl.mobileCtrl,
                decoration: const InputDecoration(labelText: 'Mobile'),
              ),
              TextField(
                controller: ctrl.skillsCtrl,
                decoration: const InputDecoration(labelText: 'Skills (comma-separated)'),
              ),
              TextField(
                controller: ctrl.techStackCtrl,
                decoration: const InputDecoration(labelText: 'Tech Stack (comma-separated)'),
              ),
              TextField(
                controller: ctrl.educationCtrl,
                decoration: const InputDecoration(labelText: 'Education (comma-separated)'),
              ),
              TextField(
                controller: ctrl.experienceCtrl,
                decoration: const InputDecoration(labelText: 'Experience (years)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ctrl.availabilityCtrl,
                decoration: const InputDecoration(labelText: 'Availability'),
              ),
              TextField(
                controller: ctrl.chargesCtrl,
                decoration: const InputDecoration(labelText: 'Charges'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ctrl.currentSalaryCtrl,
                decoration: const InputDecoration(labelText: 'Current Salary'),
                keyboardType: TextInputType.number,
              ),
              Obx(() => CheckboxListTile(title: const Text('Itfuturz Candidate'), value: ctrl.isCandidate.value, onChanged: (value) => ctrl.isCandidate.value = value ?? false)),
              Obx(
                () => DropdownButton<String>(
                  value: ctrl.candidateStatus.value,
                  items: ['Available', 'Not Available'].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                  onChanged: (value) => ctrl.candidateStatus.value = value ?? 'Available',
                  hint: const Text('Status'),
                ),
              ),
              ListTile(title: Text(ctrl.profileImage.value?.name ?? 'Select Profile Image'), trailing: const Icon(Icons.upload), onTap: () => ctrl.pickFile('profileImage')),
              ListTile(title: Text(ctrl.resume.value?.name ?? 'Select Resume'), trailing: const Icon(Icons.upload), onTap: () => ctrl.pickFile('resume')),
              ListTile(title: Text(ctrl.aadhaarCard.value?.name ?? 'Select Aadhaar Card'), trailing: const Icon(Icons.upload), onTap: () => ctrl.pickFile('aadharCard')),
              ListTile(title: Text(ctrl.panCard.value?.name ?? 'Select PAN Card'), trailing: const Icon(Icons.upload), onTap: () => ctrl.pickFile('panCard')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ctrl.createCandidate(candidateId: candidate['_id']);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> candidate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(candidate['name'] ?? 'Unknown'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Candidate Code: ${candidate['candidateCode'] ?? 'N/A'}'),
              Text('Mobile: ${candidate['mobile'] ?? 'N/A'}'),
              Text('Skills: ${candidate['skills']?.join(', ') ?? 'N/A'}'),
              Text('Tech Stack: ${candidate['techStack']?.join(', ') ?? 'N/A'}'),
              Text('Education: ${candidate['education']?.join(', ') ?? 'N/A'}'),
              Text('Experience: ${candidate['experience']?.toString() ?? '0'} years'),
              Text('Availability: ${candidate['availability'] ?? 'N/A'}'),
              Text('Charges: ${candidate['charges']?.toString() ?? '0'}'),
              Text('Current Salary: ${candidate['currentSalary']?.toString() ?? '0'}'),
              Text('Status: ${candidate['status'] ?? 'N/A'}'),
              Text('Itfuturz Candidate: ${candidate['itfuturzCandidate'] ?? false}'),
              Text('Profile Completed: ${candidate['isProfilCompleted'] ?? false ? 'Yes' : 'No'}'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }
}
