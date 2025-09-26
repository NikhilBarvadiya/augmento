import 'package:augmento/utils/config/app_config.dart';
import 'package:augmento/utils/decoration.dart';
import 'package:augmento/utils/network/api_config.dart';
import 'package:augmento/views/dashboard/tabs/candidates/ui/candidate_form.dart';
import 'package:augmento/views/dashboard/tabs/job_management/ui/skill_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'candidates_ctrl.dart';

class Candidates extends StatelessWidget {
  const Candidates({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CandidatesCtrl>(
      init: CandidatesCtrl(),
      builder: (ctrl) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchAndFilters(ctrl),
            Expanded(child: _buildCandidatesList(ctrl)),
          ],
        ),
        floatingActionButton: _buildFAB(context, ctrl),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Candidates', style: TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: decoration.colorScheme.primary,
      foregroundColor: decoration.colorScheme.onPrimary,
    );
  }

  Widget _buildSearchAndFilters(CandidatesCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [_buildSearchBar(ctrl), const SizedBox(height: 12), _buildFilterRow(ctrl), const SizedBox(height: 8), _buildProfileCompletedFilter(ctrl)]),
    );
  }

  Widget _buildSearchBar(CandidatesCtrl ctrl) {
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

  Widget _buildFilterRow(CandidatesCtrl ctrl) {
    return Row(
      children: [
        Expanded(child: _buildStatusFilter(ctrl)),
        const SizedBox(width: 12),
        Expanded(child: _buildAvailabilityFilter(ctrl)),
      ],
    );
  }

  Widget _buildStatusFilter(CandidatesCtrl ctrl) {
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
            hint: const Text('Status', style: TextStyle(fontSize: 14)),
            isExpanded: true,
            items: [
              const DropdownMenuItem(value: '', child: Text('All Statuses')),
              const DropdownMenuItem(value: 'Available', child: Text('Available')),
              const DropdownMenuItem(value: 'Not Available', child: Text('Not Available')),
            ],
            onChanged: (value) => ctrl.statusFilter.value = value ?? '',
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityFilter(CandidatesCtrl ctrl) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: ctrl.availabilityFilter.value.isEmpty ? null : ctrl.availabilityFilter.value,
            hint: const Text('Availability', style: TextStyle(fontSize: 14)),
            isExpanded: true,
            items: [
              const DropdownMenuItem(value: '', child: Text('All Availabilities')),
              const DropdownMenuItem(value: 'Immediate', child: Text('Immediate')),
              const DropdownMenuItem(value: '1 Week', child: Text('1 Week')),
              const DropdownMenuItem(value: '2 Weeks', child: Text('2 Weeks')),
              const DropdownMenuItem(value: '1 Month', child: Text('1 Month')),
              const DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (value) => ctrl.availabilityFilter.value = value ?? '',
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCompletedFilter(CandidatesCtrl ctrl) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
        child: SwitchListTile(
          title: const Text('Profile Completed Only', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          value: ctrl.isProfileCompletedFilter.value,
          onChanged: (value) => ctrl.isProfileCompletedFilter.value = value,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          dense: true,
        ),
      ),
    );
  }

  Widget _buildCandidatesList(CandidatesCtrl ctrl) {
    return RefreshIndicator(
      onRefresh: () => ctrl.fetchCandidates(reset: true),
      child: Obx(() {
        if (ctrl.isLoading.value && ctrl.candidates.isEmpty) {
          return _buildShimmerList();
        }
        if (ctrl.candidates.isEmpty) {
          return _buildEmptyState();
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!ctrl.isLoading.value && ctrl.hasMore.value && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
              ctrl.fetchCandidates();
            }
            return false;
          },
          child: ListView.separated(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: Get.height * 0.1),
            physics: BouncingScrollPhysics(),
            itemCount: ctrl.candidates.length + (ctrl.hasMore.value ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index < ctrl.candidates.length) {
                return _buildCandidateCard(context, ctrl, ctrl.candidates[index]);
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
                _buildShimmerContainer(50, 50, isCircular: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildShimmerContainer(120, 16), const SizedBox(height: 8), _buildShimmerContainer(80, 14)]),
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

  Widget _buildShimmerContainer(double width, double height, {bool isCircular = false, double borderRadius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: isCircular ? null : BorderRadius.circular(borderRadius), shape: isCircular ? BoxShape.circle : BoxShape.rectangle),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No candidates found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text('Try adjusting your search or filters', style: TextStyle(color: Colors.grey[500])),
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

  Widget _buildCandidateCard(BuildContext context, CandidatesCtrl ctrl, Map<String, dynamic> candidate) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailsDialog(context, candidate),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(ctrl, candidate),
              const SizedBox(height: 12),
              SkillSection(candidate: candidate),
              const SizedBox(height: 12),
              _buildStatusAndAvailability(candidate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(CandidatesCtrl ctrl, Map<String, dynamic> candidate) {
    return Row(
      children: [
        _buildAvatar(candidate),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(candidate['name']?.toString().capitalizeFirst ?? 'Unknown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(candidate['candidateCode'] ?? 'No Code', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
        _buildActionMenu(ctrl, candidate),
      ],
    );
  }

  Widget _buildAvatar(Map<String, dynamic> candidate) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[200]!, width: 2),
      ),
      child: CircleAvatar(
        radius: 25,
        backgroundImage: candidate['profileImage'] != null ? NetworkImage('${APIConfig.resourceBaseURL}/${candidate['profileImage']}') : null,
        child: candidate['profileImage'] == null ? Icon(Icons.person, color: Colors.grey[600]) : null,
      ),
    );
  }

  Widget _buildActionMenu(CandidatesCtrl ctrl, Map<String, dynamic> candidate) {
    return PopupMenuButton<String>(
      color: Colors.white,
      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) => _handleMenuAction(value, ctrl, candidate),
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
        PopupMenuItem(
          value: 'status',
          child: Row(
            children: [
              Icon(Icons.change_circle_rounded, size: 20, color: candidate['status'] == 'Available' ? Colors.red : Colors.blue),
              const SizedBox(width: 8),
              Text('Mark ${candidate['status'] == 'Available' ? 'Unavailable' : 'Available'}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusAndAvailability(Map<String, dynamic> candidate) {
    return Row(
      children: [
        _buildStatusChip(candidate['status']),
        const SizedBox(width: 8),
        _buildAvailabilityChip(candidate['availability']),
        const Spacer(),
        Text(
          "${AppConfig.rupee} ${candidate["charges"].toString()}",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String? status) {
    final isAvailable = status == 'Available';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: isAvailable ? Colors.green[50] : Colors.red[50], borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: isAvailable ? Colors.green : Colors.red, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status ?? 'Unknown',
            style: TextStyle(fontSize: 11, color: isAvailable ? Colors.green[700] : Colors.red[700], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityChip(String? availability) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12)),
      child: Text(
        availability ?? 'Not specified',
        style: TextStyle(fontSize: 11, color: Colors.orange[700], fontWeight: FontWeight.w500),
      ),
    );
  }

  Future<void> _handleMenuAction(String action, CandidatesCtrl ctrl, Map<String, dynamic> candidate) async {
    switch (action) {
      case 'edit':
        ctrl.clearForm();
        Get.to(() => CandidateForm(candidate: candidate, isEdit: true));
        break;
      case 'delete':
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.delete, color: Color(0xFFEF4444)),
                SizedBox(width: 8),
                Text('Delete Candidates'),
              ],
            ),
            content: const Text('Are you sure you want to delete this candidates? This action cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  ctrl.deleteCandidates([candidate['_id']]);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        break;
      case 'status':
        ctrl.changeCandidateStatus(candidate['_id'], candidate['status'] == 'Available' ? 'Not Available' : 'Available');
        break;
    }
  }

  Widget _buildFAB(BuildContext context, CandidatesCtrl ctrl) {
    return FloatingActionButton.extended(
      onPressed: () {
        ctrl.clearForm();
        Get.to(() => const CandidateForm());
      },
      icon: const Icon(Icons.add),
      label: const Text('Add Candidate'),
      foregroundColor: Colors.white,
      backgroundColor: decoration.colorScheme.primary,
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> candidate) {
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
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: candidate['profileImage'] != null ? NetworkImage('${APIConfig.resourceBaseURL}/${candidate['profileImage']}') : null,
                      backgroundColor: decoration.colorScheme.primaryContainer,
                      child: candidate['profileImage'] == null ? const Icon(Icons.person, size: 30, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        candidate['name'] ?? 'Unknown',
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
                      _buildSectionTitle('Personal Details'),
                      _buildDetailRow('Candidate Code', candidate['candidateCode']),
                      _buildDetailRow('Mobile', candidate['mobile']),
                      _buildDetailRow('Status', candidate['status']),
                      _buildDetailRow('Profile Completed', (candidate['isProfilCompleted'] ?? false) ? 'Yes' : 'No'),
                      _buildDetailRow('IT Futurz Candidate', (candidate['itfuturzCandidate'] ?? false) ? 'Yes' : 'No'),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Professional Details'),
                      _buildChipRow('Skills', candidate['skills']),
                      _buildChipRow('Tech Stack', candidate['techStack']),
                      _buildChipRow('Education', candidate['education']),
                      _buildDetailRow('Experience', '${candidate['experience'] ?? 0} years'),
                      _buildDetailRow('Availability', candidate['availability']),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Financial Details'),
                      _buildDetailRow('Charges', candidate['charges']?.toString()),
                      _buildDetailRow('Current Salary', candidate['currentSalary']?.toString()),
                      if (candidate['resume'] != null && candidate['resume'].isNotEmpty) ...[const SizedBox(height: 16), _buildSectionTitle('Resume')],
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
                    children: items
                        .map(
                          (item) => Chip(
                            label: Text(item.toString(), style: TextStyle(fontSize: 12, color: decoration.colorScheme.primary)),
                            backgroundColor: decoration.colorScheme.secondaryContainer,
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
