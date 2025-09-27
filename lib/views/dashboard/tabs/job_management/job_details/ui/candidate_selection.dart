import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_details/job_details_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CandidateSelection extends StatelessWidget {
  final String? jobId;

  const CandidateSelection({super.key, this.jobId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobDetailsCtrl>();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Select Candidates',
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(16),
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
                            onChanged: (value) => controller.searchQuery.value = value,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(() {
                          if (controller.isLoading.value && controller.candidates.isEmpty) {
                            return const Center(
                              child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
                            );
                          }
                          if (controller.candidates.isEmpty) {
                            return _buildEmptyState('No candidates found', Icons.person_search_rounded);
                          }
                          return Column(
                            children: controller.candidates.map((candidate) {
                              return Obx(() => _buildCandidateCard(candidate, controller));
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.selectedCandidates.isEmpty || jobId == null
                            ? null
                            : () {
                                controller.applyForJob(jobId!);
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
                          controller.selectedCandidates.isEmpty ? 'Apply' : 'Apply (${controller.selectedCandidates.length} selected)',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                      label: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
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
}
