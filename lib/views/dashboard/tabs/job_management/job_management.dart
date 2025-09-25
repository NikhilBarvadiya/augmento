import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_filter/job_filter.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_management_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_details/job_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class JobsManagement extends StatelessWidget {
  final int initialTab;
  final Map<String, dynamic>? initialFilter;

  const JobsManagement({super.key, this.initialTab = 0, this.initialFilter});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JobsCtrl>(
      init: JobsCtrl(initialTab: initialTab, initialFilter: initialFilter),
      builder: (ctrl) => DefaultTabController(
        initialIndex: initialTab,
        length: 5,
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(ctrl),
          body: Column(
            children: [
              _buildTabBar(ctrl),
              Expanded(child: _buildTabViews(ctrl)),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(JobsCtrl ctrl) {
    return AppBar(
      title: const Text(
        'Job Management',
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
      actions: [
        if (ctrl.initialTab == 0)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
              onPressed: () => Get.to(() => const JobFilter()),
            ),
          ),
      ],
    );
  }

  Widget _buildTabBar(JobsCtrl ctrl) {
    return Container(
      color: Colors.white,
      child: Obx(
        () => TabBar(
          isScrollable: true,
          labelColor: decoration.colorScheme.primary,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          indicatorColor: decoration.colorScheme.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabAlignment: TabAlignment.start,
          onTap: (index) => ctrl.onTabChanged(index),
          tabs: [
            _buildTab('Available', ctrl.counts['publishedJobs'] ?? 0, Icons.work_outline_rounded),
            _buildTab('Applied', _getAppliedCount(ctrl), Icons.send_rounded),
            _buildTab('Selected', ctrl.counts['applicationStatusCounts']?.firstWhere((e) => e['status'] == 'Selected', orElse: () => {'count': 0})['count'] ?? 0, Icons.check_circle_outline_rounded),
            _buildTab('Rejected', ctrl.counts['applicationStatusCounts']?.firstWhere((e) => e['status'] == 'Rejected', orElse: () => {'count': 0})['count'] ?? 0, Icons.cancel_outlined),
            _buildTab('Onboard', ctrl.counts['onboarding'] ?? 0, Icons.person_add_rounded),
          ],
        ),
      ),
    );
  }

  int _getAppliedCount(JobsCtrl ctrl) {
    final scheduled = ctrl.counts['applicationStatusCounts']?.firstWhere((e) => e['status'] == 'Scheduled' || e['status'] == 'Pending', orElse: () => {'count': 0})['count'] ?? 0;
    return scheduled;
  }

  Tab _buildTab(String label, int count, IconData icon) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: decoration.colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '$count',
                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabViews(JobsCtrl ctrl) {
    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildJobList(ctrl, 'available', ctrl.availableJobs, ctrl.fetchAvailableJobs),
        _buildJobList(ctrl, 'applied', ctrl.appliedJobs, ctrl.fetchStatusWiseJobs, status: ['Pending']),
        _buildJobList(ctrl, 'selected', ctrl.selectedJobs, ctrl.fetchStatusWiseJobs, status: ['Selected']),
        _buildJobList(ctrl, 'rejected', ctrl.rejectedJobs, ctrl.fetchStatusWiseJobs, status: ['Rejected']),
        _buildJobList(ctrl, 'onboard', ctrl.onboardJobs, ctrl.fetchOnboardJobs, status: ['Accepted', 'Rejected', 'Pending']),
      ],
    );
  }

  Widget _buildSearchAndFilters(JobsCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: _buildSearchBar(ctrl),
    );
  }

  Widget _buildSearchBar(JobsCtrl ctrl) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600], size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => ctrl.searchQuery.value = value,
            ),
          ),
        ),
        if (ctrl.initialTab == 4) ...[const SizedBox(width: 12), Expanded(child: _buildStatusFilter(ctrl))],
      ],
    );
  }

  Widget _buildStatusFilter(JobsCtrl ctrl) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: ctrl.statusFilter.value.isEmpty ? null : ctrl.statusFilter.value,
            hint: Text('All Status', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: '', child: Text('All')),
              DropdownMenuItem(value: 'Accepted', child: Text('Accepted')),
              DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
              DropdownMenuItem(value: 'Pending', child: Text('Pending')),
            ],
            onChanged: (value) => ctrl.statusFilter.value = value ?? '',
          ),
        ),
      ),
    );
  }

  Widget _buildJobList(JobsCtrl ctrl, String type, RxList jobs, Function fetchFunction, {List<String>? status}) {
    return Column(
      children: [
        _buildSearchAndFilters(ctrl),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => fetchFunction(reset: true, status: status),
            color: decoration.colorScheme.primary,
            child: Obx(() {
              if (ctrl.isLoading.value && jobs.isEmpty) return _buildShimmerList();
              if (jobs.isEmpty) return _buildEmptyState(type);
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!ctrl.isLoading.value && ctrl.hasMore[type] == true && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                    fetchFunction(status: status);
                  }
                  return false;
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: jobs.length + (ctrl.hasMore[type] == true ? 1 : 0),
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index < jobs.length) return _buildJobCard(context, ctrl, jobs[index], type);
                    return _buildLoadMoreIndicator();
                  },
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(padding: const EdgeInsets.all(16), itemCount: 6, separatorBuilder: (context, index) => const SizedBox(height: 16), itemBuilder: (context, index) => _buildShimmerCard());
  }

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildShimmerContainer(56, 56, isCircular: true),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildShimmerContainer(160, 18), const SizedBox(height: 8), _buildShimmerContainer(100, 14)]),
                ),
                _buildShimmerContainer(32, 32, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 16),
            _buildShimmerContainer(double.infinity, 16),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildShimmerContainer(80, 24, borderRadius: 12),
                const SizedBox(width: 8),
                _buildShimmerContainer(100, 24, borderRadius: 12),
                const SizedBox(width: 8),
                _buildShimmerContainer(90, 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 16),
            Row(children: [_buildShimmerContainer(120, 24, borderRadius: 12), const SizedBox(width: 8), _buildShimmerContainer(140, 24, borderRadius: 12)]),
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

  Widget _buildEmptyState(String type) {
    Map<String, Map<String, dynamic>> stateConfig = {
      'available': {'icon': Icons.work_off_outlined, 'title': 'No Jobs Available', 'subtitle': 'Check back later for new opportunities'},
      'applied': {'icon': Icons.inbox_outlined, 'title': 'No Applications', 'subtitle': 'Applied jobs will appear here'},
      'selected': {'icon': Icons.check_circle_outline, 'title': 'No Selected Candidates', 'subtitle': 'Selected applications will show here'},
      'rejected': {'icon': Icons.cancel_outlined, 'title': 'No Rejections', 'subtitle': 'Rejected applications will appear here'},
      'onboard': {'icon': Icons.person_add_outlined, 'title': 'No Onboarding', 'subtitle': 'Onboarding processes will show here'},
    };

    final config = stateConfig[type] ?? stateConfig['available']!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(60)),
            child: Icon(config['icon'], size: 60, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            config['title'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(config['subtitle'], style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(decoration.colorScheme.primary), strokeWidth: 3)),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, JobsCtrl ctrl, Map<String, dynamic> job, String type) {
    String jobApplicationId = job["_id"] ?? "";
    String createdAt = job["createdAt"] ?? "";
    List candidates = job["candidates"] ?? [];

    if (job["job"] != null) {
      job = job["job"] ?? {};
    } else if (job["jobDetails"] != null) {
      job = job["jobDetails"] ?? {};
    }
    job["createdAt"] = createdAt;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => JobDetails(job: job, candidates: candidates, jobApplicationId: jobApplicationId, type: type)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(ctrl, job, type),
                const SizedBox(height: 16),
                if (candidates.isNotEmpty) _buildCandidatesSection(candidates),
                _buildSkillsSection(job),
                const SizedBox(height: 16),
                _buildDetailsRow(job),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(JobsCtrl ctrl, Map<String, dynamic> job, String type) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.work_outline_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job['jobTitle']?.toString().capitalizeFirst.toString() ?? 'Unknown Job',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(job['createdAt']),
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Date not available';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM d, yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
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
                candidate['candidateDetails']?['name'] ?? 'Unknown',
                style: TextStyle(fontSize: 11, color: Colors.blue[700], fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSkillsSection(Map<String, dynamic> job) {
    final requiredSkills = job['requiredSkills'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.code_rounded, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              'Required Skills',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        requiredSkills.isNotEmpty
            ? Wrap(
                spacing: 6,
                runSpacing: 6,
                children: requiredSkills.take(4).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple[200]!),
                    ),
                    child: Text(
                      skill.toString(),
                      style: TextStyle(fontSize: 11, color: Colors.purple[700], fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Text('No skills specified', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ),
      ],
    );
  }

  Widget _buildDetailsRow(Map<String, dynamic> job) {
    return Row(
      children: [
        Expanded(child: _buildDetailChip('Type: ${job['jobType'] ?? 'N/A'}', Icons.business_center_outlined, Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: _buildDetailChip('Salary: ₹${job['minSalary'] ?? 'N/A'} - ₹${job['maxSalary'] ?? 'N/A'}', Icons.payments_outlined, Colors.orange)),
      ],
    );
  }

  Widget _buildDetailChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.withOpacity(.7)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 10, color: color.withOpacity(.7), fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
