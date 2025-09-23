import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/dashboard_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/account/account.dart';
import 'package:augmento/views/dashboard/tabs/candidates_tab.dart';
import 'package:augmento/views/dashboard/tabs/home_tab.dart';
import 'package:augmento/views/dashboard/tabs/jobs_tab.dart';
import 'package:augmento/views/dashboard/tabs/projects_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardCtrl>(
      init: DashboardCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)]),
            ),
            child: SafeArea(
              child: Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0.1, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic)),
                        child: child,
                      ),
                    );
                  },
                  child: _getCurrentTab(ctrl.currentIndex.value),
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildProfessionalBottomNav(ctrl),
          floatingActionButton: _buildVendorFAB(context, ctrl),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  Widget _buildProfessionalBottomNav(DashboardCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, -10))],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        color: Colors.white,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProfessionalNavItem(Icons.dashboard_outlined, Icons.dashboard, 'Overview', 0, ctrl),
              _buildProfessionalNavItem(Icons.people_outline, Icons.people, 'Candidates', 1, ctrl),
              const SizedBox(width: 50),
              _buildProfessionalNavItem(Icons.folder_outlined, Icons.folder, 'Projects', 3, ctrl),
              _buildProfessionalNavItem(Icons.person_outline, Icons.person, 'Profile', 4, ctrl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalNavItem(IconData outlineIcon, IconData filledIcon, String label, int index, DashboardCtrl ctrl) {
    return Obx(() {
      final isSelected = ctrl.currentIndex.value == index;
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ctrl.changeTabIndex(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(color: isSelected ? decoration.colorScheme.primary.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(isSelected ? filledIcon : outlineIcon, key: ValueKey(isSelected), color: isSelected ? decoration.colorScheme.primary : const Color(0xFF64748B), size: 24),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(color: isSelected ? decoration.colorScheme.primary : const Color(0xFF64748B), fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500),
                child: Text(label),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildVendorFAB(BuildContext context, DashboardCtrl ctrl) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primaryContainer], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: decoration.colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          ctrl.changeTabIndex(2);
          _showVendorQuickActions(context, ctrl);
        },
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        child: const Icon(Icons.work_outline, size: 26),
      ),
    );
  }

  Widget _getCurrentTab(int index) {
    switch (index) {
      case 0:
        return const HomeTab(key: ValueKey(0));
      case 1:
        return const CandidatesTab(key: ValueKey(1));
      case 2:
        return const JobsTab(key: ValueKey(2));
      case 3:
        return const ProjectsTab(key: ValueKey(3));
      case 4:
        return const Account(key: ValueKey(4));
      default:
        return const HomeTab(key: ValueKey(0));
    }
  }

  void _showVendorQuickActions(BuildContext context, DashboardCtrl ctrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildVendorQuickAction(Icons.add_circle_outline, 'Post New Job', 'Create a job posting', const Color(0xFF10B981), () => Navigator.pop(context))),
                const SizedBox(width: 16),
                Expanded(child: _buildVendorQuickAction(Icons.people_outline, 'Browse Talent', 'Find candidates', const Color(0xFF3B82F6), () => Navigator.pop(context))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildVendorQuickAction(Icons.analytics_outlined, 'View Analytics', 'Job performance', const Color(0xFF8B5CF6), () => Navigator.pop(context))),
                const SizedBox(width: 16),
                Expanded(child: _buildVendorQuickAction(Icons.schedule_outlined, 'Interviews', 'Manage schedule', const Color(0xFFF59E0B), () => Navigator.pop(context))),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorQuickAction(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
