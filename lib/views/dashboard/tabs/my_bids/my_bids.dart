import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/my_bids/my_bids_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/my_bids/ui/bid_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class MyBids extends StatefulWidget {
  const MyBids({super.key});

  @override
  State<MyBids> createState() => _MyBidsState();
}

class _MyBidsState extends State<MyBids> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyBidsCtrl>(
      init: MyBidsCtrl(),
      builder: (ctrl) => Scaffold(
        backgroundColor: decoration.colorScheme.surfaceContainerLowest,
        appBar: _buildAppBar(),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) => ctrl.changeTabIndex(index),
          children: [_buildBidsList(ctrl, 'all'), _buildBidsList(ctrl, 'pending'), _buildBidsList(ctrl, 'accepted'), _buildBidsList(ctrl, 'rejected')],
        ),
        bottomNavigationBar: _buildBottomTabBar(ctrl),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'My Bids',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: decoration.colorScheme.primary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.close(1),
        ),
      ),
    );
  }

  Widget _buildBottomTabBar(MyBidsCtrl ctrl) {
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
                _buildBottomTabItem(icon: Icons.list_rounded, label: 'All Bids', count: ctrl.bids.length, index: 0, isSelected: ctrl.currentTab.value == 0, onTap: () => _onTabTapped(0, ctrl)),
                _buildBottomTabItem(
                  icon: Icons.pending_actions_rounded,
                  label: 'Pending',
                  count: ctrl.bids.where((bid) => bid['status'] == 'pending').length,
                  index: 1,
                  isSelected: ctrl.currentTab.value == 1,
                  onTap: () => _onTabTapped(1, ctrl),
                ),
                _buildBottomTabItem(
                  icon: Icons.check_circle_rounded,
                  label: 'Accepted',
                  count: ctrl.bids.where((bid) => bid['status'] == 'accepted').length,
                  index: 2,
                  isSelected: ctrl.currentTab.value == 2,
                  onTap: () => _onTabTapped(2, ctrl),
                ),
                _buildBottomTabItem(
                  icon: Icons.cancel_rounded,
                  label: 'Rejected',
                  count: ctrl.bids.where((bid) => bid['status'] == 'rejected').length,
                  index: 3,
                  isSelected: ctrl.currentTab.value == 3,
                  onTap: () => _onTabTapped(3, ctrl),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: decoration.allBorderRadius(10.0),
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
      ),
    );
  }

  void _onTabTapped(int index, MyBidsCtrl ctrl) {
    _pageController.jumpToPage(index);
    ctrl.currentTab.value = index;
    final statuses = ['all', 'pending', 'accepted', 'rejected'];
    ctrl.changeStatusFilter(statuses[index]);
  }

  Widget _buildSearchBar(MyBidsCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: decoration.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: decoration.colorScheme.outline.withOpacity(0.15)),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search bids...',
            hintStyle: TextStyle(fontSize: 14, color: decoration.colorScheme.onSurfaceVariant.withOpacity(0.6)),
            prefixIcon: Icon(Icons.search_rounded, color: decoration.colorScheme.primary, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (value) => ctrl.updateSearchQuery(value),
        ),
      ),
    );
  }

  Widget _buildBidsList(MyBidsCtrl ctrl, String status) {
    return Column(
      children: [
        _buildSearchBar(ctrl),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ctrl.fetchMyBids(reset: true),
            color: decoration.colorScheme.primary,
            child: Obx(() {
              final filteredBids = status == 'all' ? ctrl.bids : ctrl.bids.where((bid) => bid['status'] == status).toList();
              if (ctrl.isLoading.value && ctrl.bids.isEmpty) {
                return _buildShimmerList();
              }
              if (filteredBids.isEmpty) {
                return _buildEmptyState(status);
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!ctrl.isLoading.value && ctrl.hasMore.value && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                    ctrl.fetchMyBids();
                  }
                  return false;
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredBids.length + (ctrl.hasMore.value ? 1 : 0),
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index < filteredBids.length) {
                      return _buildBidCard(filteredBids[index], ctrl);
                    } else {
                      return _buildLoadMoreIndicator();
                    }
                  },
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildBidCard(Map<String, dynamic> bid, MyBidsCtrl ctrl) {
    final project = bid['project'] as Map<String, dynamic>;
    final status = bid['status'] as String;
    final coverLetter = bid['coverLetter'] as String;
    final bidAmount = bid['bidAmount'];
    final duration = bid['duration'] as String;
    final createdAt = bid['createdAt'] as String;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => BidDetails(bid: bid)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBidHeader(project, status, ctrl),
                const SizedBox(height: 12),
                _buildProjectInfo(project, coverLetter),
                const SizedBox(height: 16),
                _buildBidInfo(bidAmount, duration, createdAt),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSkillsSection(project)),
                    _buildStatusBadge(status, ctrl),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBidHeader(Map<String, dynamic> project, String status, MyBidsCtrl ctrl) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project['title']?.toString().capitalizeFirst ?? 'Unknown Project',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${project['scope']?.toString().capitalizeFirst} • ${project['experienceLevel']?.toString().capitalizeFirst}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, MyBidsCtrl ctrl) {
    final color = ctrl.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.capitalizeFirst ?? '',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfo(Map<String, dynamic> project, String coverLetter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project['description']?.toString() ?? 'No description available',
          style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          "Letter: ${coverLetter.toString()}",
          style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        if (project['budget'] != null) _buildBudgetInfo(project['budget']),
      ],
    );
  }

  Widget _buildBudgetInfo(Map<String, dynamic> budget) {
    String budgetText = '';
    if (budget['fixedRate'] != null) {
      budgetText = 'Budget: ₹${budget['fixedRate']}';
    } else if (budget['hourlyFrom'] != null && budget['hourlyTo'] != null) {
      budgetText = 'Budget: ₹${budget['hourlyFrom']} - ₹${budget['hourlyTo']}/hr';
    }
    if (budgetText.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(
          budgetText,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBidInfo(dynamic bidAmount, String duration, String createdAt) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildInfoItem('My Bid', '₹$bidAmount', Icons.currency_rupee_rounded, Colors.blue)),
          Container(width: 1, height: 30, color: Colors.blue.withOpacity(0.3)),
          Expanded(child: _buildInfoItem('Duration', duration, Icons.schedule_rounded, Colors.blue)),
          Container(width: 1, height: 30, color: Colors.blue.withOpacity(0.3)),
          Expanded(child: _buildInfoItem('Submitted', decoration.formatDate(createdAt), Icons.calendar_today_rounded, Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSkillsSection(Map<String, dynamic> project) {
    final skills = project['skills'] as List? ?? [];
    if (skills.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Skills:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: skills.take(3).map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Text(
                skill.toString(),
                style: const TextStyle(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildShimmerContainer(50, 50, borderRadius: 12),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildShimmerContainer(double.infinity, 16), const SizedBox(height: 8), _buildShimmerContainer(100, 12)]),
                ),
                _buildShimmerContainer(80, 24, borderRadius: 20),
              ],
            ),
            const SizedBox(height: 12),
            _buildShimmerContainer(double.infinity, 14),
            const SizedBox(height: 8),
            _buildShimmerContainer(double.infinity, 14),
            const SizedBox(height: 8),
            _buildShimmerContainer(120, 20, borderRadius: 8),
            const SizedBox(height: 16),
            _buildShimmerContainer(double.infinity, 60, borderRadius: 12),
            const SizedBox(height: 12),
            Row(children: [_buildShimmerContainer(80, 24, borderRadius: 8), const SizedBox(width: 8), _buildShimmerContainer(100, 24, borderRadius: 8)]),
          ],
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

  Widget _buildEmptyState(String status) {
    final Map<String, Map<String, dynamic>> stateConfig = {
      'all': {'icon': Icons.inbox_outlined, 'title': 'No Bids Yet', 'subtitle': 'Start bidding on projects to see them here'},
      'pending': {'icon': Icons.pending_actions_outlined, 'title': 'No Pending Bids', 'subtitle': 'Your pending bids will appear here'},
      'accepted': {'icon': Icons.check_circle_outline, 'title': 'No Accepted Bids', 'subtitle': 'Accepted bids will show here'},
      'rejected': {'icon': Icons.cancel_outlined, 'title': 'No Rejected Bids', 'subtitle': 'Rejected bids will appear here'},
    };

    final config = stateConfig[status] ?? stateConfig['all']!;

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
