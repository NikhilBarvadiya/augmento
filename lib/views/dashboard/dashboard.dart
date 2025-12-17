import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/dashboard_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/candidate_requirements/candidate_requirements.dart';
import 'package:augmento/views/dashboard/tabs/candidates/candidates.dart';
import 'package:augmento/views/dashboard/tabs/digital_products/digital_products.dart';
import 'package:augmento/views/dashboard/tabs/home/home.dart';
import 'package:augmento/views/dashboard/tabs/projects/projects.dart';
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
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (ctrl.currentIndex.value == 0) {
              _showExitConfirmationDialog(context, ctrl);
            } else {
              ctrl.changeTabIndex(0);
            }
          },
          child: Scaffold(
            backgroundColor: decoration.colorScheme.surface,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [decoration.colorScheme.surface, decoration.colorScheme.surfaceContainerLowest]),
              ),
              child: Obx(() => _getCurrentTab(ctrl.currentIndex.value)),
            ),
            bottomNavigationBar: _buildModernBottomNav(ctrl),
          ),
        );
      },
    );
  }

  Widget _buildModernBottomNav(DashboardCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, -8), spreadRadius: 0)],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0, ctrl: ctrl),
              _buildNavItem(icon: Icons.people_rounded, label: 'Candidates', index: 1, ctrl: ctrl),
              _buildNavItem(icon: Icons.assignment_rounded, label: 'Requirements', index: 2, ctrl: ctrl),
              _buildNavItem(icon: Icons.inventory_2_rounded, label: 'Products', index: 3, ctrl: ctrl),
              _buildNavItem(icon: Icons.workspace_premium_rounded, label: 'Bids', index: 4, ctrl: ctrl, showBadge: true, badgeCount: ctrl.counts['publishedProjects']?.toString() ?? '0'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index, required DashboardCtrl ctrl, bool showBadge = false, String badgeCount = '0'}) {
    return Obx(() {
      final isSelected = ctrl.currentIndex.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            ctrl.changeTabIndex(index);
          },
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
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: isSelected ? decoration.colorScheme.primary : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                      child: Icon(icon, color: isSelected ? Colors.white : decoration.colorScheme.onSurfaceVariant, size: 24),
                    ),
                    if (showBadge && badgeCount != '0')
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            badgeCount,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showExitConfirmationDialog(BuildContext context, DashboardCtrl ctrl) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.exit_to_app_rounded, color: Color(0xFFEF4444), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Exit App', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('Are you sure you want to exit Augmento Staff?', style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5)),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Get.close(1),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Get.close(1);
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Exit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _getCurrentTab(int index) {
    switch (index) {
      case 0:
        return const Home(key: ValueKey(0));
      case 1:
        return const Candidates(key: ValueKey(1));
      case 2:
        return const CandidateRequirements(key: ValueKey(2));
      case 3:
        return const DigitalProducts(key: ValueKey(3));
      case 4:
        return const Projects(key: ValueKey(4));
      default:
        return const Home(key: ValueKey(0));
    }
  }
}
