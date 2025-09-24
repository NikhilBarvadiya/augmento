import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/dashboard_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/account/account.dart';
import 'package:augmento/views/dashboard/tabs/candidates/candidates.dart';
import 'package:augmento/views/dashboard/tabs/home/home.dart';
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

  Widget _getCurrentTab(int index) {
    switch (index) {
      case 0:
        return const Home(key: ValueKey(0));
      case 1:
        return const Candidates(key: ValueKey(1));
      case 2:
        return const JobsTab(key: ValueKey(2));
      case 3:
        return const ProjectsTab(key: ValueKey(3));
      case 4:
        return const Account(key: ValueKey(4));
      default:
        return const Home(key: ValueKey(0));
    }
  }
}
