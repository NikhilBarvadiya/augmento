import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_management.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecentJobDetailsCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final String type;

  const RecentJobDetailsCard({super.key, required this.job, required this.type});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> jobDetails = job["jobId"] ?? {};
    List candidates = job["candidate"] ?? [];
    return Container(
      width: Get.width * .92 - 10,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => JobsManagement(initialTab: 1)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildCardHeader(jobDetails, type), const SizedBox(height: 16), if (candidates.isNotEmpty) _buildCandidatesSection(candidates)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(Map<String, dynamic> job, String type) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.work_outline_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            job['jobTitle']?.toString().capitalizeFirst.toString() ?? 'Unknown Job',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 16, color: decoration.colorScheme.primary),
      ],
    );
  }

  Widget _buildCandidatesSection(List candidates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people_outline_rounded, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              'Applied Candidates (${candidates.length})',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: candidates.take(3).map((candidate) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                candidate['name'] ?? 'Unknown',
                style: TextStyle(fontSize: 11, color: Colors.blue[700], fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
