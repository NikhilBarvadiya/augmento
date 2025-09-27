import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_details/job_details_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_details/ui/onboarding_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppliedCandidates extends StatelessWidget {
  final List? candidates;
  final String? jobId;
  final String? jobApplicationId;

  const AppliedCandidates({super.key, this.candidates, this.jobId, this.jobApplicationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Applied Candidates',
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
      body: SingleChildScrollView(
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
                  onPressed: () => _navigateToOnboardingScreen(candidate),
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

  void _navigateToOnboardingScreen(Map<String, dynamic> candidate) {
    final controller = Get.find<JobDetailsCtrl>();
    controller.resetOnboardingStep();
    Get.to(
      () => OnboardingForm(candidate: candidate, jobId: jobId, jobApplicationId: jobApplicationId),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}
