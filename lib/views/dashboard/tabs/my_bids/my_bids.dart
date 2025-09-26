import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/my_bids/my_bids_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/my_bids/ui/bid_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyBids extends StatelessWidget {
  const MyBids({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyBidsCtrl>(
      init: MyBidsCtrl(),
      builder: (ctrl) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildStatusTabs(ctrl),
            _buildSearchBar(ctrl),
            Expanded(child: _buildBidsList(ctrl)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('My Bids', style: TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _buildStatusTabs(MyBidsCtrl ctrl) {
    final statuses = [
      {'key': 'all', 'label': 'All'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'accepted', 'label': 'Accepted'},
      {'key': 'rejected', 'label': 'Rejected'},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Obx(
        () => Row(
          children: statuses.map((status) {
            final isSelected = ctrl.statusFilter.value == status['key'];
            final count = ctrl.getBidCountByStatus(status['key'] as String);
            return Expanded(
              child: GestureDetector(
                onTap: () => ctrl.changeStatusFilter(status['key'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(color: isSelected ? decoration.colorScheme.primary.withOpacity(0.08) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        count.toString(),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isSelected ? decoration.colorScheme.primary : Colors.grey[700]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status['label'] as String,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isSelected ? decoration.colorScheme.primary : Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchBar(MyBidsCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search bids by project name...',
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) => ctrl.updateSearchQuery(value),
        ),
      ),
    );
  }

  Widget _buildBidsList(MyBidsCtrl ctrl) {
    return RefreshIndicator(
      onRefresh: () => ctrl.fetchMyBids(reset: true),
      child: Obx(() {
        if (ctrl.isLoading.value && ctrl.bids.isEmpty) {
          return _buildShimmerList();
        }
        if (ctrl.bids.isEmpty) {
          return _buildEmptyState();
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
            itemCount: ctrl.bids.length + (ctrl.hasMore.value ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index < ctrl.bids.length) {
                return _buildBidCard(ctrl.bids[index], ctrl);
              } else {
                return _buildLoadMoreIndicator();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildBidCard(Map<String, dynamic> bid, MyBidsCtrl ctrl) {
    final project = bid['project'] as Map<String, dynamic>;
    final status = bid['status'] as String;
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
                _buildProjectInfo(project),
                const SizedBox(height: 16),
                _buildBidInfo(bidAmount, duration, createdAt),
                const SizedBox(height: 12),
                _buildSkillsSection(project),
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
          child: const Icon(Icons.work_outline_rounded, color: Colors.white, size: 24),
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
        _buildStatusBadge(status, ctrl),
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

  Widget _buildProjectInfo(Map<String, dynamic> project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project['description']?.toString() ?? 'No description available',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
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
          Expanded(child: _buildInfoItem('My Bid', '₹$bidAmount', Icons.currency_rupee, Colors.blue)),
          Container(width: 1, height: 30, color: Colors.blue.withOpacity(0.3)),
          Expanded(child: _buildInfoItem('Duration', duration, Icons.schedule, Colors.blue)),
          Container(width: 1, height: 30, color: Colors.blue.withOpacity(0.3)),
          Expanded(child: _buildInfoItem('Submitted', _formatDate(createdAt), Icons.calendar_today, Colors.blue)),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmerContainer(50, 50, isCircular: true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildShimmerContainer(150, 16), const SizedBox(height: 8), _buildShimmerContainer(100, 12)]),
              ),
              _buildShimmerContainer(80, 24, borderRadius: 20),
            ],
          ),
          const SizedBox(height: 12),
          _buildShimmerContainer(double.infinity, 14),
          const SizedBox(height: 8),
          _buildShimmerContainer(120, 20, borderRadius: 8),
          const SizedBox(height: 16),
          _buildShimmerContainer(double.infinity, 40, borderRadius: 12),
        ],
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
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No bids found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text('You haven\'t submitted any bids yet', style: TextStyle(color: Colors.grey[500])),
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM d').format(date);
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
