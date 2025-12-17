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
            backgroundColor: const Color(0xFFF8FAFC),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)]),
              ),
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
            bottomNavigationBar: _buildProfessionalBottomNav(ctrl),
          ),
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
        child: Row(
          children: [
            _buildProfessionalNavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', 0, ctrl),
            _buildProfessionalNavItem(Icons.people_outline, Icons.people, 'Candidates', 1, ctrl),
            _buildProfessionalNavItem(Icons.pending_actions_outlined, Icons.pending_actions_rounded, 'Requirements', 2, ctrl),
            _buildProfessionalNavItem(Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Products', 3, ctrl),
            _buildProfessionalNavItem(Icons.gavel_outlined, Icons.gavel, 'Bids', 4, ctrl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalNavItem(IconData outlineIcon, IconData filledIcon, String label, int index, DashboardCtrl ctrl) {
    return Obx(() {
      final isSelected = ctrl.currentIndex.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ctrl.changeTabIndex(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(color: isSelected ? decoration.colorScheme.primary.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Badge(
                  isLabelVisible: index == 4,
                  label: Text(ctrl.counts['publishedProjects']?.toString() ?? '0'),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(isSelected ? filledIcon : outlineIcon, key: ValueKey(isSelected), color: isSelected ? decoration.colorScheme.primary : const Color(0xFF64748B), size: 24),
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(color: isSelected ? decoration.colorScheme.primary : const Color(0xFF64748B), fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.exit_to_app, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Exit App'),
          ],
        ),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(onPressed: () => Get.close(1), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.close(1);
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: EdgeInsets.only(top: 5, bottom: 5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Exit'),
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
