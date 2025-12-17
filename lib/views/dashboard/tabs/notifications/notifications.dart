import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/notifications/notifications_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsCtrl>(
      init: NotificationsCtrl(),
      builder: (ctrl) => DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _buildSearchBar(ctrl),
              Expanded(child: _buildTabViews(ctrl)),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: decoration.colorScheme.primary,
      foregroundColor: decoration.colorScheme.onPrimary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.close(1),
        ),
      ),
    );
  }

  Widget _buildSearchBar(NotificationsCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search notifications...',
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

  Widget _buildTabViews(NotificationsCtrl ctrl) {
    return TabBarView(physics: const NeverScrollableScrollPhysics(), children: [_buildNotificationsList(ctrl, 'all'), _buildNotificationsList(ctrl, 'read'), _buildNotificationsList(ctrl, 'unread')]);
  }

  Widget _buildNotificationsList(NotificationsCtrl ctrl, String status) {
    return RefreshIndicator(
      onRefresh: () => ctrl.fetchNotifications(reset: true),
      child: Obx(() {
        final filteredNotifications = status == 'all' ? ctrl.notifications : ctrl.notifications.where((notification) => notification['status'] == status).toList();
        if (ctrl.isLoading.value && ctrl.notifications.isEmpty) {
          return _buildShimmerList();
        }
        if (filteredNotifications.isEmpty) {
          return _buildEmptyState();
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!ctrl.isLoading.value && ctrl.hasMore.value && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
              ctrl.fetchNotifications();
            }
            return false;
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: filteredNotifications.length + (ctrl.hasMore.value ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index < filteredNotifications.length) {
                return _buildNotificationCard(filteredNotifications[index], ctrl);
              } else {
                return _buildLoadMoreIndicator();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, NotificationsCtrl ctrl) {
    final createdAt = notification['createdAt'] as String;
    final status = notification['status'] as String;
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildNotificationHeader(notification, status, ctrl), const SizedBox(height: 12), _buildNotificationInfo(notification, createdAt)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationHeader(Map<String, dynamic> notification, String status, NotificationsCtrl ctrl) {
    final eventType = notification['eventType'] as String;
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getEventIcon(eventType), color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getEventTitle(eventType),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                notification['message']?.toString() ?? 'No message',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = status == 'read' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.capitalizeFirst ?? '',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationInfo(Map<String, dynamic> notification, String createdAt) {
    final relatedId = notification['relatedId'] as Map<String, dynamic>?;
    final jobDescriptionId = notification['jobDescriptionId'] as Map<String, dynamic>?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (relatedId != null && relatedId['title'] != null) ...[
          Text(
            'Project: ${relatedId['title']}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
        ],
        if (jobDescriptionId != null && jobDescriptionId['jobTitle'] != null) ...[
          Text(
            'Job: ${jobDescriptionId['jobTitle']}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                'Received: ${decoration.formatDate(createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ),
            _buildStatusBadge(notification["status"]),
          ],
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
              _buildShimmerContainer(50, 50, borderRadius: 12),
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
        ],
      ),
    );
  }

  Widget _buildShimmerContainer(double width, double height, {double borderRadius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(borderRadius)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text('You haven\'t received any notifications yet', style: TextStyle(color: Colors.grey[500])),
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

  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case 'PROJECT_CREATED':
        return Icons.work_outline_rounded;
      case 'INTERVIEW_SCHEDULED':
        return Icons.schedule;
      case 'JD_UPLOADED':
        return Icons.upload_file;
      default:
        return Icons.notifications;
    }
  }

  String _getEventTitle(String eventType) {
    switch (eventType) {
      case 'PROJECT_CREATED':
        return 'New Project';
      case 'INTERVIEW_SCHEDULED':
        return 'Interview Scheduled';
      case 'JD_UPLOADED':
        return 'Job Description Uploaded';
      default:
        return 'Notification';
    }
  }
}
