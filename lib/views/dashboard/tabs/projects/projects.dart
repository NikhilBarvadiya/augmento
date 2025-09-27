import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/my_bids/my_bids.dart';
import 'package:augmento/views/dashboard/tabs/projects/projects_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/projects/ui/projects_details_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Projects extends StatelessWidget {
  const Projects({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectsCtrl>(
      init: ProjectsCtrl(),
      builder: (ctrl) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchAndFilters(ctrl),
            Expanded(child: _buildProjectsList(ctrl)),
          ],
        ),
        floatingActionButton: _buildFAB(context, ctrl),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Vendor Projects', style: TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: decoration.colorScheme.primary,
      foregroundColor: decoration.colorScheme.onPrimary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(ProjectsCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [_buildSearchBar(ctrl), const SizedBox(height: 12), _buildFilterRow(ctrl)]),
    );
  }

  Widget _buildSearchBar(ProjectsCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search projects...',
          hintStyle: const TextStyle(fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) => ctrl.searchQuery.value = value,
      ),
    );
  }

  Widget _buildFilterRow(ProjectsCtrl ctrl) {
    return Row(
      children: [
        Expanded(child: _buildExperienceLevelFilter(ctrl)),
        const SizedBox(width: 12),
        Expanded(child: _buildScopeFilter(ctrl)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatusFilter(ctrl)),
      ],
    );
  }

  Widget _buildExperienceLevelFilter(ProjectsCtrl ctrl) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: ctrl.experienceLevelFilter.value.isEmpty ? null : ctrl.experienceLevelFilter.value,
            hint: const Text('All Levels', style: TextStyle(fontSize: 14)),
            isExpanded: true,
            items: [
              const DropdownMenuItem(value: '', child: Text('All Levels')),
              const DropdownMenuItem(value: 'entry', child: Text('Entry')),
              const DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
              const DropdownMenuItem(value: 'expert', child: Text('Expert')),
            ],
            onChanged: (value) => ctrl.experienceLevelFilter.value = value ?? '',
          ),
        ),
      ),
    );
  }

  Widget _buildScopeFilter(ProjectsCtrl ctrl) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: ctrl.scopeFilter.value.isEmpty ? null : ctrl.scopeFilter.value,
            hint: const Text('Scope', style: TextStyle(fontSize: 14)),
            isExpanded: true,
            items: [
              const DropdownMenuItem(value: '', child: Text('All Scopes')),
              const DropdownMenuItem(value: 'small', child: Text('Small')),
              const DropdownMenuItem(value: 'medium', child: Text('Medium')),
              const DropdownMenuItem(value: 'large', child: Text('Large')),
            ],
            onChanged: (value) => ctrl.scopeFilter.value = value ?? '',
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter(ProjectsCtrl ctrl) {
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
              const DropdownMenuItem(value: '', child: Text('All Status')),
              const DropdownMenuItem(value: 'open', child: Text('Open')),
              const DropdownMenuItem(value: 'closed', child: Text('Closed')),
            ],
            onChanged: (value) => ctrl.statusFilter.value = value ?? '',
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsList(ProjectsCtrl ctrl) {
    return RefreshIndicator(
      onRefresh: () => ctrl.fetchProjects(reset: true),
      child: Obx(() {
        if (ctrl.isLoading.value && ctrl.projects.isEmpty) {
          return _buildShimmerList();
        }
        if (ctrl.projects.isEmpty) {
          return _buildEmptyState();
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!ctrl.isLoading.value && ctrl.hasMore.value && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
              ctrl.fetchProjects();
            }
            return false;
          },
          child: ListView.separated(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: Get.height * 0.1),
            physics: const BouncingScrollPhysics(),
            itemCount: ctrl.projects.length + (ctrl.hasMore.value ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index < ctrl.projects.length) {
                return ProjectsDetailsCard(project: ctrl.projects[index]).paddingOnly(bottom: 15);
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
          Icon(Icons.work_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No projects found',
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

  Widget _buildFAB(BuildContext context, ProjectsCtrl ctrl) {
    return FloatingActionButton.extended(
      onPressed:  () => Get.to(() => MyBids()),
      icon: const Icon(Icons.gavel),
      label: const Text('My Bids'),
      foregroundColor: Colors.white,
      backgroundColor: decoration.colorScheme.primary,
    );
  }
}
