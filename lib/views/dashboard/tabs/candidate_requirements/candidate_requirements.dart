import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/candidate_requirements/ui/requirement_form.dart';
import 'package:augmento/views/dashboard/tabs/job_management/ui/skill_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'candidate_requirements_ctrl.dart';

class CandidateRequirements extends StatelessWidget {
  const CandidateRequirements({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CandidateRequirementsCtrl>(
      init: CandidateRequirementsCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _buildSearchAndFilters(ctrl),
              _buildStatsCard(ctrl),
              Expanded(child: _buildRequirementsList(ctrl)),
            ],
          ),
          floatingActionButton: _buildFAB(context, ctrl),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Job Requirements', style: TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: decoration.colorScheme.primary,
      foregroundColor: decoration.colorScheme.onPrimary,
    );
  }

  Widget _buildStatsCard(CandidateRequirementsCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total', ctrl.stats['total']?.toString() ?? '0', Colors.blue),
            _buildVerticalDivider(),
            _buildStatItem('Active', ctrl.stats['active']?.toString() ?? '0', Colors.green),
            _buildVerticalDivider(),
            _buildStatItem('Inactive', ctrl.stats['inactive']?.toString() ?? '0', Colors.red),
            _buildVerticalDivider(),
            _buildStatItem('Draft', ctrl.stats['draft']?.toString() ?? '0', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Row(
      spacing: 8.0,
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 40, color: Colors.grey[300]);
  }

  Widget _buildSearchAndFilters(CandidateRequirementsCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        spacing: 10.0,
        children: [
          Expanded(flex: 2, child: _buildSearchBar(ctrl)),
          Expanded(child: _buildStatusFilter(ctrl)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(CandidateRequirementsCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search here...',
          hintStyle: TextStyle(fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) => ctrl.searchQuery.value = value,
      ),
    );
  }

  Widget _buildStatusFilter(CandidateRequirementsCtrl ctrl) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: ctrl.statusFilter.value.isEmpty ? null : ctrl.statusFilter.value,
            hint: const Text('All Status', style: TextStyle(fontSize: 14)),
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: '', child: Text('All Status')),
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
              DropdownMenuItem(value: 'Draft', child: Text('Draft')),
            ],
            onChanged: (value) => ctrl.statusFilter.value = value ?? '',
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementsList(CandidateRequirementsCtrl ctrl) {
    return RefreshIndicator(
      onRefresh: () async {
        await ctrl.fetchRequirements(reset: true);
        await ctrl.fetchStats();
      },
      child: Obx(() {
        if (ctrl.isLoading.value && ctrl.requirements.isEmpty) {
          return _buildShimmerList();
        }
        if (ctrl.requirements.isEmpty) {
          return _buildEmptyState();
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!ctrl.isLoading.value && ctrl.hasMore.value && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
              ctrl.fetchRequirements();
            }
            return false;
          },
          child: ListView.separated(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: Get.height * 0.1),
            physics: const BouncingScrollPhysics(),
            itemCount: ctrl.requirements.length + (ctrl.hasMore.value ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index < ctrl.requirements.length) {
                return _buildRequirementCard(context, ctrl, ctrl.requirements[index]);
              } else {
                return _buildLoadMoreIndicator();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(padding: const EdgeInsets.all(16), itemCount: 6, separatorBuilder: (context, index) => const SizedBox(height: 12), itemBuilder: (context, index) => _buildShimmerCard());
  }

  Widget _buildShimmerCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildShimmerContainer(150, 18), const SizedBox(height: 8), _buildShimmerContainer(100, 14)]),
                ),
                _buildShimmerContainer(24, 24),
              ],
            ),
            const SizedBox(height: 12),
            _buildShimmerContainer(double.infinity, 14),
            const SizedBox(height: 8),
            Row(children: [_buildShimmerContainer(60, 20, borderRadius: 10), const SizedBox(width: 8), _buildShimmerContainer(80, 20, borderRadius: 10)]),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContainer(double width, double height, {double borderRadius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(borderRadius)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No job requirements found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text('Create your first job requirement', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(decoration.colorScheme.primary), strokeWidth: 2.5)),
    );
  }

  Widget _buildRequirementCard(BuildContext context, CandidateRequirementsCtrl ctrl, Map<String, dynamic> requirement) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailsDialog(context, requirement),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(ctrl, requirement),
              const SizedBox(height: 12),
              _buildJobDetails(requirement),
              const SizedBox(height: 12),
              SkillSection(candidate: requirement),
              const SizedBox(height: 12),
              _buildStatusAndSalary(requirement),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(CandidateRequirementsCtrl ctrl, Map<String, dynamic> requirement) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.work, color: decoration.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(requirement['jobTitle']?.toString().capitalizeFirst ?? 'Unknown Position', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(requirement['location'] ?? 'Location not specified', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
        _buildActionMenu(ctrl, requirement),
      ],
    );
  }

  Widget _buildActionMenu(CandidateRequirementsCtrl ctrl, Map<String, dynamic> requirement) {
    return PopupMenuButton<String>(
      color: Colors.white,
      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) => _handleMenuAction(value, ctrl, requirement),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobDetails(Map<String, dynamic> requirement) {
    return Row(
      children: [
        _buildDetailChip(requirement['jobType'] ?? 'N/A', Icons.schedule, Colors.blue),
        const SizedBox(width: 8),
        _buildDetailChip(requirement['experienceLevel'] ?? 'N/A', Icons.trending_up, Colors.green),
      ],
    );
  }

  Widget _buildDetailChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusAndSalary(Map<String, dynamic> requirement) {
    final salaryRange = requirement['salaryRange'] as Map<String, dynamic>?;
    final minSalary = salaryRange?['min']?.toString() ?? '0';
    final maxSalary = salaryRange?['max']?.toString() ?? '0';
    final currency = salaryRange?['currency'] ?? 'INR';
    return Row(
      children: [
        _buildStatusChip(requirement['status']),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
          child: Text(
            '$minSalary-$maxSalary $currency',
            style: TextStyle(fontSize: 11, color: Colors.green[700], fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    switch (status) {
      case 'Active':
        color = Colors.green;
        break;
      case 'Inactive':
        color = Colors.red;
        break;
      case 'Draft':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status ?? 'Unknown',
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, CandidateRequirementsCtrl ctrl, Map<String, dynamic> requirement) {
    switch (action) {
      case 'edit':
        Get.to(() => RequirementForm(requirement: requirement, isEdit: true));
        break;
      case 'delete':
        ctrl.deleteRequirement(requirement['_id']);
        break;
    }
  }

  Widget _buildFAB(BuildContext context, CandidateRequirementsCtrl ctrl) {
    return FloatingActionButton.extended(
      onPressed: () => Get.to(() => const RequirementForm()),
      icon: const Icon(Icons.add),
      label: const Text('Add Requirement'),
      foregroundColor: Colors.white,
      backgroundColor: decoration.colorScheme.primary,
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> requirement) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        backgroundColor: Colors.white,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85, maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: decoration.colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.work, size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        requirement['jobTitle'] ?? 'Unknown',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: decoration.colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Job Details'),
                      _buildDetailRow('Job Type', requirement['jobType']),
                      _buildDetailRow('Experience Level', requirement['experienceLevel']),
                      _buildDetailRow('Location', requirement['location']),
                      _buildDetailRow('Status', requirement['status']),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Skills & Qualifications'),
                      _buildChipRow('Required Skills', requirement['requiredSkills']),
                      _buildChipRow('Preferred Skills', requirement['preferredSkills']),
                      _buildChipRow('Soft Skills', requirement['softSkills']),
                      _buildChipRow('Tech Stack', requirement['techStack']),
                      _buildChipRow('Certifications', requirement['certification']),
                      _buildChipRow('Education', requirement['educationQualification']),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Description'),
                      _buildDetailRow('Responsibilities', requirement['responsibility']),
                      _buildDetailRow('Summary', requirement['summary']),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Financial Details'),
                      _buildDetailRow(
                        'Salary Range',
                        requirement['salaryRange'] != null
                            ? '${requirement['salaryRange']['min']?.toString() ?? '0'} - ${requirement['salaryRange']['max']?.toString() ?? '0'} ${requirement['salaryRange']['currency'] ?? 'N/A'}'
                            : 'N/A',
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: decoration.colorScheme.primary,
                        foregroundColor: decoration.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: decoration.colorScheme.primary),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
            child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow(String label, List<dynamic>? items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
            child: items == null || items.isEmpty
                ? const Text('N/A', style: TextStyle(fontSize: 14, color: Colors.black87))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: items.map((item) {
                      return Chip(
                        label: Text(item.toString(), style: TextStyle(fontSize: 12, color: decoration.colorScheme.primary)),
                        backgroundColor: decoration.colorScheme.secondaryContainer,
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
