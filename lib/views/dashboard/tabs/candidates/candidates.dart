import 'package:augmento/utils/config/app_config.dart';
import 'package:augmento/utils/decoration.dart';
import 'package:augmento/utils/network/api_config.dart';
import 'package:augmento/views/dashboard/tabs/candidates/ui/candidate_details.dart';
import 'package:augmento/views/dashboard/tabs/candidates/ui/candidate_form.dart';
import 'package:augmento/views/dashboard/tabs/job_management/ui/skill_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
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
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: decoration.colorScheme.surface,
          border: Border.all(color: ctrl.statusFilter.value.isEmpty ? decoration.colorScheme.outline.withOpacity(0.3) : decoration.colorScheme.primary.withOpacity(0.5), width: .6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: ctrl.statusFilter.value.isEmpty ? null : [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: ctrl.statusFilter.value.isEmpty ? null : ctrl.statusFilter.value,
            padding: EdgeInsets.only(left: 5, right: 5),
            hint: Row(
              children: [
                Icon(Icons.filter_list_rounded, size: 20, color: decoration.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(fontSize: 13, letterSpacing: .5, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down_rounded, color: decoration.colorScheme.onSurfaceVariant, size: 24),
            style: TextStyle(fontSize: 13, letterSpacing: .5, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600, color: decoration.colorScheme.onSurface),
            dropdownColor: Colors.white,
            items: [
              DropdownMenuItem(
                value: '',
                child: Row(
                  children: [
                    Icon(Icons.clear_rounded, size: 16, color: decoration.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    const Text('All Statuses', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Available',
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: Colors.green[600], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('Available', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Not Available',
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: Colors.red[600], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('Not Available', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
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
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: decoration.colorScheme.surface,
          border: Border.all(color: ctrl.availabilityFilter.value.isEmpty ? decoration.colorScheme.outline.withOpacity(0.3) : decoration.colorScheme.primary.withOpacity(0.5), width: .6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: ctrl.availabilityFilter.value.isEmpty ? null : [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: ctrl.availabilityFilter.value.isEmpty ? null : ctrl.availabilityFilter.value,
            padding: const EdgeInsets.only(left: 5, right: 5),
            hint: Row(
              children: [
                Icon(Icons.schedule_rounded, size: 20, color: decoration.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Availability',
                    style: TextStyle(fontSize: 13, letterSpacing: .5, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down_rounded, color: decoration.colorScheme.onSurfaceVariant, size: 24),
            style: TextStyle(fontSize: 13, letterSpacing: .5, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600, color: decoration.colorScheme.onSurface),
            dropdownColor: Colors.white,
            items: [
              DropdownMenuItem(
                value: '',
                child: Row(
                  children: [
                    Icon(Icons.clear_rounded, size: 16, color: decoration.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    const Text('All Availabilities', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Immediate',
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: Colors.green[600], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('Immediate', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: '1 Week',
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: Colors.blue[600], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('1 Week', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: '2 Weeks',
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: Colors.orange[600], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('2 Weeks', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: '1 Month',
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: Colors.amber[700], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('1 Month', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Other',
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: Colors.grey[600], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('Other', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
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
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Card(
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
        onTap: () => _showCandidateDetails(context, candidate),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 12.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(ctrl, candidate),
              SkillSection(candidate: candidate),
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
        Row(
          children: [
            Text(
              "${AppConfig.rupee} ${candidate["charges"].toString()}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              "/Monthly",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ],
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
              TextButton(onPressed: () => Get.close(1), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Get.close(1);
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

  void _showCandidateDetails(BuildContext context, Map<String, dynamic> candidate) {
    Get.to(
      () => CandidateDetails(candidate: candidate),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}
