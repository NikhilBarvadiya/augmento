import 'package:augmento/utils/decoration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'home_ctrl.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<HomeCtrl>(
      init: HomeCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: decoration.colorScheme.surfaceVariant.withOpacity(0.3),
          body: RefreshIndicator(
            onRefresh: ctrl.fetchDashboardData,
            color: decoration.colorScheme.primary,
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, theme),
                SliverToBoxAdapter(child: Obx(() => _buildBody(context, ctrl, theme))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      toolbarHeight: 65,
      backgroundColor: decoration.colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8), decoration.colorScheme.secondary.withOpacity(0.6)],
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, HomeCtrl ctrl, ThemeData theme) {
    if (ctrl.isLoading.value) {
      return _buildLoadingState(theme);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _buildQuickStats(ctrl, theme),
        const SizedBox(height: 24),
        _buildMetricsSection(ctrl, theme),
        const SizedBox(height: 32),
        _buildActiveJobs(ctrl, theme),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildQuickStats(HomeCtrl ctrl, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: decoration.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('Total Jobs', ctrl.counts['jobs']?.toString() ?? '0', Icons.work_outline, Colors.blue, theme)),
          Container(width: 1, height: 40, color: theme.dividerColor),
          Expanded(child: _buildStatItem('Applications', ctrl.counts['applications']?.toString() ?? '0', Icons.description_outlined, Colors.orange, theme)),
          Container(width: 1, height: 40, color: theme.dividerColor),
          Expanded(child: _buildStatItem('Candidates', ctrl.counts['candidates']?.toString() ?? '0', Icons.people_outline, Colors.green, theme)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: decoration.colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: decoration.colorScheme.outline, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMetricsSection(HomeCtrl ctrl, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'Performance Metrics',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: decoration.colorScheme.onSurface),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard('Shortlisted', ctrl.counts['shortListed']?.toString() ?? '0', Icons.star_outline, Colors.purple, theme),
              _buildMetricCard('Pending', ctrl.counts['pendingOnboarding']?.toString() ?? '0', Icons.hourglass_empty_outlined, Colors.orange, theme),
              _buildMetricCard('Accepted', ctrl.counts['acceptedOnboarding']?.toString() ?? '0', Icons.check_circle_outline, Colors.green, theme),
              _buildMetricCard('Rejected', ctrl.counts['rejectedOnboarding']?.toString() ?? '0', Icons.cancel_outlined, Colors.red, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: decoration.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    Text(
                      value,
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: decoration.colorScheme.onSurface),
                    ),
                  ],
                ),
                const Spacer(),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(color: decoration.colorScheme.outline, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveJobs(HomeCtrl ctrl, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.work_outline, color: decoration.colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Active Jobs',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: decoration.colorScheme.onSurface),
                    ),
                  ],
                ),
                if (ctrl.activeJobs.isNotEmpty)
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: TextStyle(color: decoration.colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          if (ctrl.activeJobs.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ctrl.activeJobs.length,
              itemBuilder: (context, index) {
                final job = ctrl.activeJobs[index];
                return _buildJobCard(job, theme);
              },
            )
          else
            _buildEmptyJobsSection(theme),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: decoration.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.work_outline, color: Colors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job['jobTitle'] ?? 'Unknown Job', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(job['companyName'] ?? 'N/A', style: theme.textTheme.bodySmall?.copyWith(color: decoration.colorScheme.outline)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildJobBadge(job['jobType'] ?? 'Full-time', Colors.green, theme),
                    const SizedBox(width: 8),
                    _buildJobBadge(job['workType'] ?? 'On-site', Colors.orange, theme),
                    const SizedBox(width: 8),
                    _buildJobBadge(job['experienceLevel'] ?? 'Entry', Colors.blue, theme),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Salary: ₹${job['minSalary']} - ₹${job['maxSalary']}',
                      style: theme.textTheme.bodySmall?.copyWith(color: decoration.colorScheme.outline, fontWeight: FontWeight.w500),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: decoration.colorScheme.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobBadge(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildEmptyJobsSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: decoration.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: decoration.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: decoration.colorScheme.primaryContainer.withOpacity(0.3), shape: BoxShape.circle),
            child: Icon(Icons.work_outline, size: 40, color: decoration.colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Text('No Active Jobs', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Create your first job posting to start recruiting.',
            style: theme.textTheme.bodyMedium?.copyWith(color: decoration.colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildShimmerCard(120),
          const SizedBox(height: 24),
          _buildShimmerTitle(),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: List.generate(4, (index) => _buildShimmerCard(120)),
          ),
          const SizedBox(height: 32),
          _buildShimmerTitle(),
          const SizedBox(height: 16),
          _buildShimmerCard(200),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildShimmerTitle() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 24,
        width: 200,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
