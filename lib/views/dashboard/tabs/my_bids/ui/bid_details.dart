import 'package:augmento/utils/decoration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BidDetails extends StatelessWidget {
  final Map<String, dynamic> bid;

  const BidDetails({super.key, required this.bid});

  @override
  Widget build(BuildContext context) {
    final project = bid['project'] as Map<String, dynamic>;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 20),
            _buildProjectDetails(project),
            const SizedBox(height: 20),
            _buildBidDetails(),
            const SizedBox(height: 20),
            _buildCoverLetter(),
            if (_hasAttachments()) ...[const SizedBox(height: 20), _buildAttachments()],
            const SizedBox(height: 20),
            _buildProjectRequirements(project),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Bid Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
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

  Widget _buildStatusCard() {
    final status = bid['status'] as String;
    final createdAt = bid['createdAt'] as String;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatusIcon(status),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bid Status',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status.capitalizeFirst ?? '',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getStatusColor(status)),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Column(
              spacing: 10.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Submitted on',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text(_formatFullDate(createdAt), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    Color color = _getStatusColor(status);
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        icon = Icons.hourglass_empty;
        break;
      case 'accepted':
        icon = Icons.check_circle;
        break;
      case 'rejected':
        icon = Icons.cancel;
        break;
      default:
        icon = Icons.description;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: color, size: 30),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildProjectDetails(Map<String, dynamic> project) {
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
          _buildSectionHeader('Project Details', Icons.work_outline),
          const SizedBox(height: 16),
          Row(
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
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${project['scope']?.toString().capitalizeFirst} • ${project['experienceLevel']?.toString().capitalizeFirst}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(project['description']?.toString() ?? 'No description available', style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
          if (project['budget'] != null) ...[const SizedBox(height: 12), _buildBudgetCard(project['budget'])],
        ],
      ),
    );
  }

  Widget _buildBudgetCard(Map<String, dynamic> budget) {
    String budgetText = '', budgetType = '';
    if (budget['fixedRate'] != null) {
      budgetText = '₹${budget['fixedRate']}';
      budgetType = 'Fixed Budget';
    } else if (budget['hourlyFrom'] != null && budget['hourlyTo'] != null) {
      budgetText = '₹${budget['hourlyFrom']} - ₹${budget['hourlyTo']}/hr';
      budgetType = 'Hourly Rate';
    }

    if (budgetText.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.green, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  budgetType,
                  style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.w500),
                ),
                Text(
                  budgetText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBidDetails() {
    final bidAmount = bid['bidAmount'];
    final duration = bid['duration'] as String;

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
          _buildSectionHeader('Your Bid Details', Icons.local_offer),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildBidInfoCard('Bid Amount', '₹$bidAmount', Icons.currency_rupee, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildBidInfoCard('Duration', duration, Icons.schedule, Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBidInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCoverLetter() {
    final coverLetter = bid['coverLetter'] as String? ?? '';

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
          _buildSectionHeader('Cover Letter', Icons.description),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(coverLetter.isNotEmpty ? coverLetter : 'No cover letter provided', style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments() {
    final attachments = bid['attachments'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildSectionHeader('Supporting Documents', Icons.attachment), const SizedBox(height: 16), ...attachments.map((attachment) => _buildAttachmentItem(attachment))],
      ),
    );
  }

  Widget _buildAttachmentItem(String attachment) {
    final fileName = attachment.split('/').last;
    final fileExtension = fileName.split('.').last.toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _getFileIcon(fileExtension),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => _downloadFile(attachment),
            icon: const Icon(Icons.download, color: Colors.blue, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _getFileIcon(String extension) {
    IconData icon;
    Color color;

    switch (extension) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        color = Colors.blue;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        icon = Icons.image;
        color = Colors.green;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 24);
  }

  Widget _buildProjectRequirements(Map<String, dynamic> project) {
    final skills = project['skills'] as List? ?? [];
    final techStack = project['techStack'] as List? ?? [];

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
          _buildSectionHeader('Project Requirements', Icons.checklist),
          const SizedBox(height: 16),
          if (skills.isNotEmpty) ...[_buildRequirementSection('Required Skills', skills, Colors.purple), const SizedBox(height: 16)],
          if (techStack.isNotEmpty) ...[_buildRequirementSection('Tech Stack', techStack, Colors.teal)],
        ],
      ),
    );
  }

  Widget _buildRequirementSection(String title, List skills, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                skill.toString(),
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: decoration.colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'accepted':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }

  bool _hasAttachments() {
    final attachments = bid['attachments'] as List? ?? [];
    return attachments.isNotEmpty;
  }

  String _formatFullDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy at h:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _downloadFile(String filePath) {
    // TODO: Implement file download functionality
    // This would typically involve calling your API to get the file URL
    // and then using url_launcher to open it
    Get.snackbar('Download', 'File download functionality to be implemented', snackPosition: SnackPosition.BOTTOM);
  }
}
