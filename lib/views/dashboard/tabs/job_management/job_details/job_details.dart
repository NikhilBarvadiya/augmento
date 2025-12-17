import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_details/job_details_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_details/ui/applied_candidates.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_details/ui/candidate_selection.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildJobHeader(job ?? {}),
              const SizedBox(height: 16),
              _buildJobDetailsCard(job ?? {}),
              const SizedBox(height: 24),
              _buildActionSection(context, controller, type ?? "", job?['_id'] ?? ""),
              const SizedBox(height: 16),
            ],
          ),
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
          onPressed: () => Get.close(1),
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
        child: Row(
          spacing: 20.0,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Icon(Icons.work_outline_rounded, size: 40, color: Colors.white),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['jobTitle'] ?? 'Unknown Position',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: .5),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      'Posted: ${job['createdAt'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(job['createdAt']).toLocal()) : 'N/A'}',
                      style: const TextStyle(fontSize: 12, letterSpacing: .5, color: Colors.white, fontWeight: FontWeight.w500),
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

  Widget _buildActionSection(BuildContext context, JobDetailsCtrl ctrl, String type, String? jobId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (type != 'available') ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => AppliedCandidates(candidates: candidates, jobId: job?['_id']));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: decoration.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.people_rounded, size: 18),
                label: const Text('Applied Candidates', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (type == 'available') ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => CandidateSelection(jobId: jobId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: decoration.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.people_rounded, size: 18),
                label: const Text('Select Candidates', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.close(1),
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
}
