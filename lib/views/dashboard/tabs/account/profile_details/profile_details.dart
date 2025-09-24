import 'package:augmento/utils/decoration.dart';
import 'package:augmento/utils/routes/route_name.dart';
import 'package:augmento/views/dashboard/tabs/account/profile_details/profile_details_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileDetailsCtrl());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Obx(() {
              final user = controller.userData.value;
              return Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileSummaryCard(controller, user),
                  const SizedBox(height: 16),
                  _buildCompanyInfoCard(user),
                  const SizedBox(height: 16),
                  _buildBusinessDetailsCard(user),
                  const SizedBox(height: 16),
                  _buildBankingInfoCard(user),
                  const SizedBox(height: 16),
                  _buildDocumentsCard(user),
                  const SizedBox(height: 100),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [decoration.colorScheme.primary, decoration.colorScheme.secondary]),
        ),
      ),
      title: const Text(
        'Profile',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.toNamed(AppRouteNames.profileEdit);
          },
          icon: const Icon(Icons.edit),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget _buildProfileSummaryCard(ProfileDetailsCtrl controller, Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 12),
                    const Text(
                      'Profile Overview',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        '${(controller.getCompletionPercentage() * 100).toInt()}% Complete',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: controller.getCompletionPercentage(),
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  minHeight: 8,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildQuickStat(Icons.business, 'Company', user['company'] ?? 'Not set', const Color(0xFF3B82F6))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildQuickStat(Icons.email, 'Email', user['email'] ?? 'Not set', const Color(0xFF10B981))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildQuickStat(Icons.phone, 'Mobile', user['mobile'] ?? 'Not set', const Color(0xFF8B5CF6))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildQuickStat(Icons.location_on, 'Location', user['address']?.split(',').first ?? 'Not set', const Color(0xFFF59E0B))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoCard(Map<String, dynamic> user) {
    return _buildInfoCard('Company Information', Icons.business, const Color(0xFF3B82F6), [
      _buildInfoRow('Company Name', user['company'], Icons.business),
      _buildInfoRow('Website', user['website'], Icons.language),
      _buildInfoRow('GST Number', user['gstNumber'], Icons.receipt_long),
      _buildInfoRow('Address', user['address'], Icons.location_on),
    ]);
  }

  Widget _buildBusinessDetailsCard(Map<String, dynamic> user) {
    var engagementModels = <String>[].obs, timeZones = <String>[].obs;
    if (user['engagementModels'] is List) {
      engagementModels.addAll((user['engagementModels'] as List).cast<String>().where((item) => item.trim().isNotEmpty));
    } else if (user['engagementModels'] is String) {
      final models = (user['engagementModels'] as String).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      engagementModels.addAll(models);
    }
    if (user['timeZones'] is List) {
      timeZones.addAll((user['timeZones'] as List).cast<String>().where((item) => item.trim().isNotEmpty));
    } else if (user['timeZones'] is String) {
      final zones = (user['timeZones'] as String).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      timeZones.addAll(zones);
    }
    return _buildInfoCard('Business Details', Icons.work_outline, const Color(0xFF10B981), [
      if (engagementModels.isNotEmpty) _buildChipRow('Engagement Models', engagementModels, Icons.handshake),
      if (timeZones.isNotEmpty) _buildChipRow('Time Zones', timeZones, Icons.schedule),
      _buildInfoRow('Available Resources', user['resourceCount']?.toString(), Icons.people_alt),
      _buildInfoRow('Comments', user['comments'], Icons.comment),
    ]);
  }

  Widget _buildBankingInfoCard(Map<String, dynamic> user) {
    return _buildInfoCard('Banking Information', Icons.account_balance, const Color(0xFF8B5CF6), [
      _buildInfoRow('Account Holder', user['bankAccountHolderName'], Icons.person),
      _buildInfoRow('Account Number', _maskAccountNumber(user['bankAccountNumber']), Icons.account_balance_wallet),
      _buildInfoRow('Bank Name', user['bankName'], Icons.account_balance),
      _buildInfoRow('Branch', user['bankBranchName'], Icons.location_city),
      _buildInfoRow('IFSC Code', user['ifscCode'], Icons.code),
    ]);
  }

  Widget _buildDocumentsCard(Map<String, dynamic> user) {
    return _buildInfoCard('Documents & Verification', Icons.verified, const Color(0xFFF59E0B), [
      _buildDocumentStatus('PAN Card', user['panCard'] != null, Icons.credit_card),
      _buildDocumentStatus('Profile Avatar', user['avatar'] != null, Icons.person),
      _buildDocumentStatus('Certificates', user['certificates']?.isNotEmpty == true, Icons.folder),
    ]);
  }

  Widget _buildInfoCard(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, IconData icon) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow(String label, List<String> items, IconData icon) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: items
                      .map(
                        (item) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
                          ),
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF3B82F6), fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStatus(String label, bool isUploaded, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: isUploaded ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isUploaded ? Icons.check_circle : Icons.cancel, size: 12, color: isUploaded ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                const SizedBox(width: 4),
                Text(
                  isUploaded ? 'Uploaded' : 'Missing',
                  style: TextStyle(fontSize: 10, color: isUploaded ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _maskAccountNumber(String? accountNumber) {
    if (accountNumber == null || accountNumber.length < 4) return accountNumber ?? 'Not set';
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }
}
