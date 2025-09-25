import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_filter/job_filter.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_management_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_details/job_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      title: const Text('Job Management', style: TextStyle(fontWeight: FontWeight.w600)),
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: true,
      backgroundColor: decoration.colorScheme.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        if (ctrl.initialTab == 0)
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              Get.to(() => JobFilter());
            },
          ),
      ],
    );
  }

  Widget _buildTabBar(JobsCtrl ctrl) {
    return Obx(
      () => TabBar(
        isScrollable: true,
        labelColor: decoration.colorScheme.primary,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: decoration.colorScheme.primary,
        tabAlignment: TabAlignment.start,
        onTap: (index) => ctrl.onTabChanged(index),
        tabs: [
          _buildTab('Available', ctrl.counts['publishedJobs'] ?? 0),
          _buildTab('Applied', _getAppliedCount(ctrl)),
          _buildTab('Selected', ctrl.counts['applicationStatusCounts']?.firstWhere((e) => e['status'] == 'Selected', orElse: () => {'count': 0})['count'] ?? 0),
          _buildTab('Rejected', ctrl.counts['applicationStatusCounts']?.firstWhere((e) => e['status'] == 'Rejected', orElse: () => {'count': 0})['count'] ?? 0),
          _buildTab('Onboard', ctrl.counts['onboarding'] ?? 0),
        ],
      ),
    );
  }

  int _getAppliedCount(JobsCtrl ctrl) {
    final scheduled = ctrl.counts['applicationStatusCounts']?.firstWhere((e) => e['status'] == 'Scheduled' || e['status'] == 'Pending', orElse: () => {'count': 0})['count'] ?? 0;
    return scheduled;
  }

  Tab _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: decoration.colorScheme.primary, borderRadius: BorderRadius.circular(12)),
              child: Text('$count', style: TextStyle(fontSize: 12, color: decoration.colorScheme.onPrimary)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabViews(JobsCtrl ctrl) {
    return TabBarView(
      physics: NeverScrollableScrollPhysics(),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: _buildSearchBar(ctrl),
    );
  }

  Widget _buildSearchBar(JobsCtrl ctrl) {
    return Row(
      spacing: 8.0,
      children: [
        Expanded(
          flex: 2,
          child: Container(
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
          ),
        ),
        if (ctrl.initialTab == 4) Expanded(child: _buildStatusFilter(ctrl)),
      ],
    );
  }

  Widget _buildStatusFilter(JobsCtrl ctrl) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: ctrl.statusFilter.value.isEmpty ? null : ctrl.statusFilter.value,
            hint: const Text('All Status', style: TextStyle(fontSize: 14)),
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
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
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

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No $type jobs found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text('Try adjusting your filters', style: TextStyle(color: Colors.grey[500])),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.to(() => JobDetails(job: job, candidates: candidates, jobApplicationId: jobApplicationId, type: type)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(ctrl, job, type),
              const SizedBox(height: 12),
              _buildDescription(job),
              const SizedBox(height: 12),
              _buildSkillsSection(job),
              const SizedBox(height: 12),
              _buildDetailsRow(job),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(JobsCtrl ctrl, Map<String, dynamic> job, String type) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.work_outline, color: decoration.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job['jobTitle'] ?? 'Unknown Job', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Posted: ${job['createdAt']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
        if (type == 'available')
          IconButton(
            icon: Icon(Icons.event_available_rounded, color: decoration.colorScheme.primary),
            onPressed: () => ctrl.applyForJob(job['_id']),
          ),
      ],
    );
  }

  Widget _buildDescription(Map<String, dynamic> job) {
    return Text(
      job['summary'] ?? job['jobDescription'] ?? 'No description',
      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSkillsSection(Map<String, dynamic> job) {
    final requiredSkills = job['requiredSkills'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Skills',
          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        requiredSkills.isNotEmpty
            ? Wrap(
                spacing: 6,
                runSpacing: 4,
                children: requiredSkills.take(3).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(skill.toString(), style: TextStyle(fontSize: 11, color: Colors.blue[700])),
                  );
                }).toList(),
              )
            : Text('No skills specified', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildDetailsRow(Map<String, dynamic> job) {
    return Row(children: [_buildDetailChip('Type: ${job['jobType'] ?? 'N/A'}'), const SizedBox(width: 8), _buildDetailChip('Salary: ${job['minSalary'] ?? ''} - ${job['maxSalary'] ?? ''}')]);
  }

  Widget _buildDetailChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: Colors.green[700])),
    );
  }
}
