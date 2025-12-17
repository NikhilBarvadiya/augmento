import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_filter/job_filter.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_management_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/job_management/ui/job_details_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class JobsManagement extends StatefulWidget {
  final int initialTab;
  final Map<String, dynamic>? initialFilter;

  const JobsManagement({super.key, this.initialTab = 0, this.initialFilter});

  @override
  State<JobsManagement> createState() => _JobsManagementState();
}

class _JobsManagementState extends State<JobsManagement> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JobsCtrl>(
      init: JobsCtrl(initialTab: widget.initialTab, initialFilter: widget.initialFilter),
      builder: (ctrl) => Scaffold(
        backgroundColor: decoration.colorScheme.surfaceContainerLowest,
        appBar: _buildAppBar(ctrl),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) => ctrl.onTabChanged(index),
          children: [
            _buildJobList(ctrl, 'available', ctrl.availableJobs, ctrl.fetchAvailableJobs),
            _buildJobList(ctrl, 'applied', ctrl.appliedJobs, ctrl.fetchStatusWiseJobs, status: ['Pending']),
            _buildJobList(ctrl, 'selected', ctrl.selectedJobs, ctrl.fetchStatusWiseJobs, status: ['Selected']),
            _buildJobList(ctrl, 'rejected', ctrl.rejectedJobs, ctrl.fetchStatusWiseJobs, status: ['Rejected']),
            _buildJobList(ctrl, 'onboard', ctrl.onboardJobs, ctrl.fetchOnboardJobs, status: ['Accepted', 'Rejected', 'Pending']),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.to(() => const JobFilter()),
          icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
          label: const Text('Filter', style: TextStyle(fontWeight: FontWeight.bold)),
          foregroundColor: Colors.white,
          backgroundColor: decoration.colorScheme.primary,
          elevation: 4,
        ),
        bottomNavigationBar: _buildBottomTabBar(ctrl),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(JobsCtrl ctrl) {
    return AppBar(
      title: const Text(
        'Job Management',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
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

  Widget _buildBottomTabBar(JobsCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomTabItem(
                  icon: Icons.work_rounded,
                  label: 'Available',
                  count: ctrl.counts['publishedJobs'] ?? 0,
                  index: 0,
                  isSelected: ctrl.initialTab == 0,
                  onTap: () => _onTabTapped(0, ctrl),
                ),
                _buildBottomTabItem(icon: Icons.send_rounded, label: 'Applied', count: _getAppliedCount(ctrl), index: 1, isSelected: ctrl.initialTab == 1, onTap: () => _onTabTapped(1, ctrl)),
                _buildBottomTabItem(
                  icon: Icons.check_circle_rounded,
                  label: 'Selected',
                  count: ctrl.counts['applicationStatusCounts']?.firstWhere((e) => e['status'] == 'Selected', orElse: () => {'count': 0})['count'] ?? 0,
                  index: 2,
                  isSelected: ctrl.initialTab == 2,
                  onTap: () => _onTabTapped(2, ctrl),
                ),
                _buildBottomTabItem(
                  icon: Icons.cancel_rounded,
                  label: 'Rejected',
                  count: ctrl.counts['applicationStatusCounts']?.firstWhere((e) => e['status'] == 'Rejected', orElse: () => {'count': 0})['count'] ?? 0,
                  index: 3,
                  isSelected: ctrl.initialTab == 3,
                  onTap: () => _onTabTapped(3, ctrl),
                ),
                _buildBottomTabItem(
                  icon: Icons.person_add_rounded,
                  label: 'Onboard',
                  count: ctrl.counts['onboarding'] ?? 0,
                  index: 4,
                  isSelected: ctrl.initialTab == 4,
                  onTap: () => _onTabTapped(4, ctrl),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTabItem({required IconData icon, required String label, required int count, required int index, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: isSelected ? decoration.colorScheme.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: isSelected ? Colors.white : decoration.colorScheme.onSurfaceVariant, size: 22),
                  ),
                  if (count > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected ? decoration.colorScheme.primary : decoration.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index, JobsCtrl ctrl) {
    _pageController.jumpToPage(index);
    ctrl.initialTab = index;
  }

  int _getAppliedCount(JobsCtrl ctrl) {
    final scheduled = ctrl.counts['applicationStatusCounts']?.firstWhere((e) => e['status'] == 'Scheduled' || e['status'] == 'Pending', orElse: () => {'count': 0})['count'] ?? 0;
    return scheduled;
  }

  Widget _buildSearchAndFilters(JobsCtrl ctrl, int tabIndex) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildSearchBar(ctrl),
          if (tabIndex == 4) ...[const SizedBox(height: 12), _buildStatusFilter(ctrl)],
        ],
      ),
    );
  }

  Widget _buildSearchBar(JobsCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: decoration.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: decoration.colorScheme.outline.withOpacity(0.15)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search jobs...',
          hintStyle: TextStyle(fontSize: 14, color: decoration.colorScheme.onSurfaceVariant.withOpacity(0.6)),
          prefixIcon: Icon(Icons.search_rounded, color: decoration.colorScheme.primary, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) => ctrl.searchQuery.value = value,
      ),
    );
  }

  Widget _buildStatusFilter(JobsCtrl ctrl) {
    return Obx(
      () => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: decoration.colorScheme.surface,
          border: Border.all(color: ctrl.statusFilter.value.isEmpty ? decoration.colorScheme.outline.withOpacity(0.3) : decoration.colorScheme.primary.withOpacity(0.5), width: 1.5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: ctrl.statusFilter.value.isEmpty ? null : [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: ctrl.statusFilter.value.isEmpty ? null : ctrl.statusFilter.value,
            hint: Row(
              children: [
                Icon(Icons.filter_list_rounded, size: 18, color: decoration.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                const Text('Filter by Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down_rounded, color: decoration.colorScheme.onSurfaceVariant),
            style: TextStyle(fontSize: 13, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600, color: decoration.colorScheme.onSurface),
            dropdownColor: Colors.white,
            items: [
              DropdownMenuItem(
                value: '',
                child: Row(
                  children: [
                    Icon(Icons.clear_rounded, size: 18, color: decoration.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 10),
                    const Text('All Status'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Accepted',
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: Colors.green[600], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    const Text('Accepted'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Pending',
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: Colors.amber[600], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    const Text('Pending'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Rejected',
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: Colors.red[600], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    const Text('Rejected'),
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

  Widget _buildJobList(JobsCtrl ctrl, String type, RxList jobs, Function fetchFunction, {List<String>? status}) {
    return Column(
      children: [
        _buildSearchAndFilters(ctrl, ctrl.initialTab),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => fetchFunction(reset: true, status: status),
            color: decoration.colorScheme.primary,
            child: Obx(() {
              if (ctrl.isLoading.value && jobs.isEmpty) {
                return _buildShimmerList();
              }
              if (jobs.isEmpty) {
                return _buildEmptyState(type);
              }
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
                    if (index < jobs.length) {
                      return JobDetailsCard(job: jobs[index], type: type);
                    }
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
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildShimmerContainer(50, 50, borderRadius: 12),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildShimmerContainer(double.infinity, 18), const SizedBox(height: 8), _buildShimmerContainer(120, 14)]),
                  ),
                  const SizedBox(width: 12),
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
      ),
    );
  }

  Widget _buildShimmerContainer(double width, double height, {double borderRadius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(borderRadius)),
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: decoration.colorScheme.primaryContainer.withOpacity(0.3), shape: BoxShape.circle),
            child: Icon(config['icon'], size: 64, color: decoration.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            config['title'],
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: decoration.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(config['subtitle'], style: TextStyle(fontSize: 14, color: decoration.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(decoration.colorScheme.primary), strokeWidth: 3)),
      ),
    );
  }
}
