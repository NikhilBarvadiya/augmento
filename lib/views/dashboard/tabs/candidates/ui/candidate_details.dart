import 'package:augmento/utils/config/app_config.dart';
import 'package:augmento/utils/decoration.dart';
import 'package:augmento/utils/helper/helper.dart';
import 'package:augmento/utils/network/api_config.dart';
import 'package:augmento/views/dashboard/tabs/candidates/candidates_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/candidates/ui/candidate_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CandidateDetails extends StatefulWidget {
  final Map<String, dynamic> candidate;

  const CandidateDetails({super.key, required this.candidate});

  @override
  State<CandidateDetails> createState() => _CandidateDetailsState();
}

class _CandidateDetailsState extends State<CandidateDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPersonalInfoCard(),
                  const SizedBox(height: 16),
                  _buildProfessionalInfoCard(),
                  const SizedBox(height: 16),
                  _buildFinancialInfoCard(),
                  const SizedBox(height: 16),
                  _buildAdditionalInfoCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildActionButtons(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 235,
      floating: false,
      pinned: true,
      backgroundColor: decoration.colorScheme.primary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8)]),
          ),
          child: SafeArea(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const SizedBox(height: 20), _buildProfileSection()]),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundImage: widget.candidate['profileImage'] != null ? NetworkImage('${APIConfig.resourceBaseURL}/${widget.candidate['profileImage']}') : null,
            backgroundColor: Colors.white,
            child: widget.candidate['profileImage'] == null ? Icon(Icons.person, size: 30, color: Colors.grey[600]) : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.candidate['name']?.toString().capitalizeFirst ?? 'Unknown',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(widget.candidate['candidateCode'] ?? 'No Code', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9))),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildStatusBadge(widget.candidate['status']), const SizedBox(width: 8), _buildAvailabilityBadge(widget.candidate['availability'])],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String? status) {
    final isAvailable = status == 'Available';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: isAvailable ? Colors.green : Colors.red, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status ?? 'Unknown',
            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityBadge(String? availability) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        availability ?? 'Not specified',
        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return _buildInfoCard('Personal Information', Icons.person_rounded, [
      _buildInfoRow('Mobile', widget.candidate['mobile'], Icons.phone),
      _buildInfoRow('Email', widget.candidate['email'], Icons.email),
      _buildInfoRow(
        'Profile Completed',
        (widget.candidate['isProfilCompleted'] ?? false) ? 'Yes' : 'No',
        Icons.check_circle,
        valueColor: (widget.candidate['isProfilCompleted'] ?? false) ? Colors.green : Colors.orange,
      ),
      _buildInfoRow(
        'IT Futurz Candidate',
        (widget.candidate['itfuturzCandidate'] ?? false) ? 'Yes' : 'No',
        Icons.verified,
        valueColor: (widget.candidate['itfuturzCandidate'] ?? false) ? Colors.blue : Colors.grey,
      ),
    ]);
  }

  Widget _buildProfessionalInfoCard() {
    return _buildInfoCard('Professional Details', Icons.work_rounded, [
      _buildChipSection('Skills', widget.candidate['skills']),
      _buildChipSection('Tech Stack', widget.candidate['techStack']),
      _buildChipSection('Education', widget.candidate['education']),
      _buildInfoRow('Experience', '${widget.candidate['experience'] ?? 0} years', Icons.timeline),
      _buildInfoRow('Current Designation', widget.candidate['currentDesignation'], Icons.badge),
      _buildInfoRow('Current Company', widget.candidate['currentCompany'], Icons.business),
    ]);
  }

  Widget _buildFinancialInfoCard() {
    return _buildInfoCard('Financial Information', Icons.attach_money_rounded, [
      _buildInfoRow(
        'Monthly Charges',
        widget.candidate['charges'] != null ? '${AppConfig.rupee} ${widget.candidate['charges']}' : null,
        Icons.currency_rupee,
        valueColor: decoration.colorScheme.primary,
        isHighlight: true,
      ),
      _buildInfoRow('Current Salary', widget.candidate['currentSalary'] != null ? '${AppConfig.rupee} ${widget.candidate['currentSalary']}' : null, Icons.payment),
      _buildInfoRow('Expected Salary', widget.candidate['expectedSalary'] != null ? '${AppConfig.rupee} ${widget.candidate['expectedSalary']}' : null, Icons.trending_up),
    ]);
  }

  Widget _buildAdditionalInfoCard() {
    return _buildInfoCard('Additional Information', Icons.info_rounded, [
      _buildInfoRow('Location', widget.candidate['location'], Icons.location_on),
      _buildInfoRow('Notice Period', widget.candidate['noticePeriod'], Icons.schedule),
      _buildInfoRow('Preferred Work Mode', widget.candidate['preferredWorkMode'], Icons.computer),
      _buildInfoRow('Languages', widget.candidate['languages'] is List ? (widget.candidate['languages'] as List).join(', ') : widget.candidate['languages'], Icons.language),
      if (widget.candidate['resume'] != null && widget.candidate['resume'].toString().isNotEmpty) _buildResumeSection(),
    ]);
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, size: 24, color: decoration.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: decoration.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, IconData icon, {Color? valueColor, bool isHighlight = false}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: (valueColor ?? Colors.grey).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: valueColor ?? Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600], letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: isHighlight ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8) : null,
                  decoration: isHighlight ? BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)) : null,
                  child: Text(
                    value,
                    style: TextStyle(fontSize: isHighlight ? 16 : 14, fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500, color: valueColor ?? Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection(String label, List<dynamic>? items) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600], letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: decoration.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: decoration.colorScheme.primary.withOpacity(0.2)),
                ),
                child: Text(
                  item.toString(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: decoration.colorScheme.primary),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.description, size: 18, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resume',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600], letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    if (widget.candidate.isNotEmpty && widget.candidate["resume"] != null && widget.candidate["resume"] != "") {
                      helper.launchURL(APIConfig.apiBaseURL + widget.candidate["resume"]);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.file_download, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'View Resume',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      spacing: 12.0,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "edit",
          onPressed: () => _handleMenuAction('edit', context),
          backgroundColor: decoration.colorScheme.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.edit),
        ),
        FloatingActionButton(
          heroTag: "delete",
          onPressed: () => _handleMenuAction('delete', context),
          backgroundColor: decoration.colorScheme.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.delete),
        ),
        FloatingActionButton.extended(
          heroTag: "status",
          onPressed: () => _handleMenuAction('status', context),
          backgroundColor: widget.candidate['status'] == 'Available' ? Colors.red : Colors.green,
          foregroundColor: Colors.white,
          icon: Icon(Icons.change_circle_rounded, size: 20),
          label: Text('Mark ${widget.candidate['status'] == 'Available' ? 'Unavailable' : 'Available'}'),
        ),
      ],
    );
  }

  void _handleMenuAction(String action, BuildContext context) {
    final ctrl = Get.find<CandidatesCtrl>();
    switch (action) {
      case 'edit':
        ctrl.clearForm();
        Get.to(() => CandidateForm(candidate: widget.candidate, isEdit: true));
        break;
      case 'delete':
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.delete, color: Color(0xFFEF4444)),
                SizedBox(width: 8),
                Text('Delete Candidate'),
              ],
            ),
            content: Text('Are you sure you want to delete ${widget.candidate['name']}? This action cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Get.close(2);
                  ctrl.deleteCandidates([widget.candidate['_id']]);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
      case 'status':
        final newStatus = widget.candidate['status'] == 'Available' ? 'Not Available' : 'Available';
        ctrl.changeCandidateStatus(widget.candidate['_id'], newStatus);
        widget.candidate['status'] = newStatus;
        setState(() {});
        break;
    }
  }
}
