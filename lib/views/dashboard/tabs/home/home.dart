import 'package:augmento/utils/decoration.dart';
import 'package:augmento/utils/routes/route_name.dart';
import 'package:augmento/views/dashboard/dashboard_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/account/account.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_management.dart';
import 'package:augmento/views/dashboard/tabs/job_management/ui/job_details_card.dart';
import 'package:augmento/views/dashboard/tabs/job_management/ui/recent_job_details_card.dart';
import 'package:augmento/views/dashboard/tabs/my_bids/my_bids.dart';
import 'package:augmento/views/dashboard/tabs/notifications/notifications.dart';
import 'package:augmento/views/dashboard/tabs/projects/projects.dart';
import 'package:augmento/views/dashboard/tabs/projects/ui/projects_details_card.dart';
import 'package:augmento/widgets/interview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
            onRefresh: ctrl.onRefresh,
            color: decoration.colorScheme.primary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
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

  String getGreetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  String getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 6) return "🌙";
    if (hour < 12) return "☀️";
    if (hour < 17) return "🌤️";
    if (hour < 20) return "🌅";
    return "🌙";
  }

  Widget _buildSliverAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      toolbarHeight: 65,
      backgroundColor: decoration.colorScheme.primary,
      flexibleSpace: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: BackgroundPatternPainter())),
          FlexibleSpaceBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Row(
                  children: [
                    Text(getGreetingEmoji(), style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      getGreetingText(),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(DateFormat('EEEE, MMM dd').format(DateTime.now()), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
              ],
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
        ],
      ),
      actions: [
        _buildHeaderButton(icon: Icons.notifications_outlined, onTap: () => Get.to(() => Notifications())),
        const SizedBox(width: 8),
        _buildHeaderButton(icon: Icons.settings_outlined, onTap: () => Get.to(() => Account())),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildHeaderButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeCtrl ctrl, ThemeData theme) {
    if (ctrl.isLoading.value) {
      return _buildLoadingState(theme);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ctrl.getCompletionPercentage() != 100) ...[
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: decoration.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Get.toNamed(AppRouteNames.profileDetails);
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics, color: decoration.colorScheme.primary),
                          const SizedBox(width: 12),
                          const Text(
                            'Profile Overview',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              '${(ctrl.getCompletionPercentage() * 100).toInt()}% Complete',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: decoration.colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: ctrl.getCompletionPercentage(),
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(decoration.colorScheme.primary),
                        minHeight: 8,
                        borderRadius: decoration.allBorderRadius(10.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        _buildQuickStats(ctrl, theme),
        const SizedBox(height: 24),
        _buildMetricsSection(ctrl, theme),
        const SizedBox(height: 15),
        if (ctrl.activeJobs.isNotEmpty) _buildActiveJobs(ctrl, theme),
        if (ctrl.jobApplications.isNotEmpty) _buildRecentJobs(ctrl, theme),
        if (ctrl.recentProjects.isNotEmpty) _buildRecentProjects(ctrl, theme),
        if (ctrl.interviews.isNotEmpty) _buildRecentInterviews(ctrl, theme),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildQuickStats(HomeCtrl ctrl, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: decoration.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        spacing: 12.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dashboard_outlined, color: decoration.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Quick Stats',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: decoration.colorScheme.onSurface),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildCompactStatItem('Jobs', ctrl.counts['jobs']?.toString() ?? '0', Icons.work_outline, Colors.blue, theme, onTap: () => Get.to(() => JobsManagement(initialTab: 0)))),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactStatItem(
                  'Applications',
                  ctrl.counts['applications']?.toString() ?? '0',
                  Icons.description_outlined,
                  Colors.orange,
                  theme,
                  onTap: () => Get.to(() => JobsManagement(initialTab: 1)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactStatItem(
                  'Candidates',
                  ctrl.counts['candidates']?.toString() ?? '0',
                  Icons.people_outline,
                  Colors.green,
                  theme,
                  onTap: () => Get.find<DashboardCtrl>().changeTabIndex(1),
                ),
              ),
            ],
          ),
          _buildInfoCard(
            title: 'Bids',
            value: ctrl.counts['totalBids']?.toString() ?? '0',
            subtitle: 'Your Bids',
            icon: Icons.local_offer_outlined,
            color: Colors.teal,
            theme: theme,
            onTap: () => Get.to(() => MyBids()),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(HomeCtrl ctrl, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: decoration.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: decoration.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Onboarding Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: decoration.colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  'Pending',
                  ctrl.counts['pendingOnboarding']?.toString() ?? '0',
                  Icons.schedule,
                  Colors.orange,
                  theme,
                  onTap: () => Get.to(() => JobsManagement(initialTab: 4, initialFilter: {'status': 'Pending'})),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusItem(
                  'Accepted',
                  ctrl.counts['acceptedOnboarding']?.toString() ?? '0',
                  Icons.check_circle_outline,
                  Colors.green,
                  theme,
                  onTap: () => Get.to(() => JobsManagement(initialTab: 4, initialFilter: {'status': 'Accepted'})),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusItem(
                  'Rejected',
                  ctrl.counts['rejectedOnboarding']?.toString() ?? '0',
                  Icons.cancel_outlined,
                  Colors.red,
                  theme,
                  onTap: () => Get.to(() => JobsManagement(initialTab: 4, initialFilter: {'status': 'Rejected'})),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem(String label, String value, IconData icon, Color color, ThemeData theme, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        highlightColor: color.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 10.0,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 24),
                  Text(
                    value,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: decoration.colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: decoration.colorScheme.outline, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String value, required String subtitle, required IconData icon, required Color color, required ThemeData theme, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: decoration.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          highlightColor: color.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 10.0,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: decoration.colorScheme.onSurface),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: decoration.colorScheme.outline, size: 14),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: decoration.colorScheme.outline, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon, Color color, ThemeData theme, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Column(
            spacing: 6.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 10.0,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Text(
                    value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: decoration.colorScheme.onSurface),
                  ),
                ],
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: decoration.colorScheme.outline, fontWeight: FontWeight.w500),
              ),
            ],
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
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.work_outline, color: decoration.colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Latest Jobs',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: decoration.colorScheme.onSurface),
                    ),
                  ],
                ),
                if (ctrl.activeJobs.isNotEmpty)
                  TextButton(
                    onPressed: () => Get.to(() => JobsManagement(initialTab: 0)),
                    child: Text(
                      'View All (${ctrl.activeJobs.length})',
                      style: TextStyle(color: decoration.colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: Get.height * .2,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: ctrl.activeJobs.length,
              itemBuilder: (context, index) {
                final job = ctrl.activeJobs[index];
                return JobDetailsCard(job: job, type: "available").paddingOnly(right: index != ctrl.activeJobs.length - 1 ? 15 : 0, bottom: 15);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentJobs(HomeCtrl ctrl, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.work_outline, color: decoration.colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Latest Applied',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: decoration.colorScheme.onSurface),
                    ),
                  ],
                ),
                if (ctrl.jobApplications.isNotEmpty)
                  TextButton(
                    onPressed: () => Get.to(() => JobsManagement(initialTab: 1)),
                    child: Text(
                      'View All (${ctrl.jobApplications.length})',
                      style: TextStyle(color: decoration.colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          if (ctrl.jobApplications.isNotEmpty)
            SizedBox(
              height: Get.height * .2,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: ctrl.jobApplications.length,
                itemBuilder: (context, index) {
                  return RecentJobDetailsCard(job: ctrl.jobApplications[index], type: "applied").paddingOnly(right: index != ctrl.jobApplications.length - 1 ? 15 : 0, bottom: 15);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentProjects(HomeCtrl ctrl, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.work_outline, color: decoration.colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Bids',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: decoration.colorScheme.onSurface),
                    ),
                  ],
                ),
                if (ctrl.recentProjects.isNotEmpty)
                  TextButton(
                    onPressed: () => Get.to(() => Projects()),
                    child: Text(
                      'View All (${ctrl.recentProjects.length})',
                      style: TextStyle(color: decoration.colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          if (ctrl.recentProjects.isNotEmpty)
            SizedBox(
              height: Get.height * .2,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: ctrl.recentProjects.length,
                itemBuilder: (context, index) {
                  return ProjectsDetailsCard(project: ctrl.recentProjects[index]).paddingOnly(right: index != ctrl.recentProjects.length - 1 ? 15 : 0, bottom: 15);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentInterviews(HomeCtrl ctrl, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 12, bottom: 16),
            child: Row(
              children: [
                Icon(Icons.work_outline, color: decoration.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Interview Updates',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: decoration.colorScheme.onSurface),
                  ),
                ),
                if (ctrl.interviews.isNotEmpty)
                  TextButton(
                    onPressed: null,
                    child: Text(
                      'Total (${ctrl.interviews.length})',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          if (ctrl.interviews.isNotEmpty)
            SizedBox(
              height: Get.height * .268,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: ctrl.interviews.length,
                itemBuilder: (context, index) {
                  return InterviewCard(interview: ctrl.interviews[index]).paddingOnly(right: index != ctrl.interviews.length - 1 ? 15 : 0, bottom: 15);
                },
              ),
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
          _buildShimmerCard(120),
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

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 40, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.1), 25, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.6), 15, paint);
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.6, size.width * 0.9, size.height * 0.9);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
