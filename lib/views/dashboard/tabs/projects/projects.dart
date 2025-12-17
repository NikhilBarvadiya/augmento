import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/my_bids/my_bids.dart';
import 'package:augmento/views/dashboard/tabs/projects/projects_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/projects/ui/projects_details_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class Projects extends StatelessWidget {
  const Projects({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectsCtrl>(
      init: ProjectsCtrl(),
      builder: (ctrl) => Scaffold(
        backgroundColor: decoration.colorScheme.surfaceContainerLowest,
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
      title: const Text('Vendor Projects', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: decoration.colorScheme.primary,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildSearchAndFilters(ProjectsCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(children: [_buildSearchBar(ctrl), const SizedBox(height: 12), _buildFilterRow(ctrl)]),
    );
  }

  Widget _buildSearchBar(ProjectsCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: decoration.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: decoration.colorScheme.outline.withOpacity(0.15)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search projects...',
          hintStyle: TextStyle(fontSize: 14, color: decoration.colorScheme.onSurfaceVariant.withOpacity(0.6)),
          prefixIcon: Icon(Icons.search_rounded, color: decoration.colorScheme.primary, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) => ctrl.searchQuery.value = value,
      ),
    );
  }

  Widget _buildFilterRow(ProjectsCtrl ctrl) {
    return Row(
      children: [
        Expanded(child: _buildExperienceLevelFilter(ctrl)),
        const SizedBox(width: 10),
        Expanded(child: _buildScopeFilter(ctrl)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatusFilter(ctrl)),
      ],
    );
  }

  Widget _buildExperienceLevelFilter(ProjectsCtrl ctrl) {
    return Obx(
      () => Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: decoration.colorScheme.surface,
          border: Border.all(color: ctrl.experienceLevelFilter.value.isEmpty ? decoration.colorScheme.outline.withOpacity(0.3) : decoration.colorScheme.primary.withOpacity(0.5), width: .6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: ctrl.experienceLevelFilter.value.isEmpty ? null : [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: ctrl.experienceLevelFilter.value.isEmpty ? null : ctrl.experienceLevelFilter.value,
            hint: Row(
              children: [
                Icon(Icons.workspace_premium_outlined, size: 16, color: decoration.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Level',
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
                    const Text('All', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'entry',
                child: Row(
                  children: [
                    Icon(Icons.star_border_rounded, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 6),
                    const Text('Entry', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'intermediate',
                child: Row(
                  children: [
                    Icon(Icons.star_half_rounded, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 6),
                    const Text('Inter', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'expert',
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: Colors.orange[600]),
                    const SizedBox(width: 6),
                    const Text('Expert', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
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
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: decoration.colorScheme.surface,
          border: Border.all(color: ctrl.scopeFilter.value.isEmpty ? decoration.colorScheme.outline.withOpacity(0.3) : decoration.colorScheme.primary.withOpacity(0.5), width: .6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: ctrl.scopeFilter.value.isEmpty ? null : [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: ctrl.scopeFilter.value.isEmpty ? null : ctrl.scopeFilter.value,
            hint: Row(
              children: [
                Icon(Icons.scale_outlined, size: 16, color: decoration.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Scope',
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
                    const Text('All', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'small',
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(4)),
                      child: Icon(Icons.circle, size: 8, color: Colors.green[700]),
                    ),
                    const SizedBox(width: 6),
                    const Text('Small', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'medium',
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(4)),
                      child: Icon(Icons.circle, size: 10, color: Colors.orange[700]),
                    ),
                    const SizedBox(width: 6),
                    const Text('Medium', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'large',
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(4)),
                      child: Icon(Icons.circle, size: 12, color: Colors.red[700]),
                    ),
                    const SizedBox(width: 6),
                    const Text('Large', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
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
            hint: Row(
              children: [
                Icon(Icons.filter_list_rounded, size: 16, color: decoration.colorScheme.onSurfaceVariant),
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
                    const Text('All', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: Colors.green[600], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('Open', style: TextStyle(letterSpacing: .5)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'closed',
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: Colors.red[600], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('Closed', style: TextStyle(letterSpacing: .5)),
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

  Widget _buildProjectsList(ProjectsCtrl ctrl) {
    return RefreshIndicator(
      onRefresh: () => ctrl.fetchProjects(reset: true),
      color: decoration.colorScheme.primary,
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
                return ProjectsDetailsCard(project: ctrl.projects[index]);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 14,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)),
              ),
              const SizedBox(height: 8),
              Container(
                width: 200,
                height: 14,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 100,
                    height: 24,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 70,
                    height: 24,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 20,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: decoration.colorScheme.primaryContainer.withOpacity(0.3), shape: BoxShape.circle),
            child: Icon(Icons.work_outline_rounded, size: 64, color: decoration.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'No projects found',
            style: TextStyle(fontSize: 20, color: decoration.colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Try adjusting your search or filters', style: TextStyle(fontSize: 14, color: decoration.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(decoration.colorScheme.primary), strokeWidth: 3)),
      ),
    );
  }

  Widget _buildFAB(BuildContext context, ProjectsCtrl ctrl) {
    return FloatingActionButton.extended(
      onPressed: () => Get.to(() => const MyBids()),
      icon: const Icon(Icons.workspace_premium_rounded),
      label: const Text('My Bids', style: TextStyle(fontWeight: FontWeight.bold)),
      foregroundColor: Colors.white,
      backgroundColor: decoration.colorScheme.primary,
      elevation: 4,
    );
  }
}
