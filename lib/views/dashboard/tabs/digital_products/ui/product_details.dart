import 'package:augmento/utils/decoration.dart';
import 'package:augmento/utils/helper/helper.dart';
import 'package:augmento/utils/network/api_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
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
                  _buildGeneralInfoCard(),
                  const SizedBox(height: 16),
                  _buildTechnicalDetailsCard(),
                  const SizedBox(height: 16),
                  _buildLinksCard(),
                  const SizedBox(height: 16),
                  _buildAdditionalInfoCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: decoration.colorScheme.primary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.close(1),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8)]),
          ),
          child: SafeArea(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const SizedBox(height: 20), _buildProductHeader()]),
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
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
            backgroundImage: widget.product['image'] != null ? NetworkImage('${APIConfig.resourceBaseURL}/${widget.product['image']}') : null,
            backgroundColor: Colors.white,
            child: widget.product['image'] == null ? Icon(Icons.image, size: 30, color: Colors.grey[600]) : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.product['title']?.toString().capitalizeFirst ?? 'Unknown Product',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildGeneralInfoCard() {
    return _buildInfoCard('General Information', Icons.info_rounded, [
      _buildInfoRow('Title', widget.product['title'], Icons.label),
      _buildInfoRow('Deleted', (widget.product['isDeleted'] ?? false) ? 'Yes' : 'No', Icons.delete, valueColor: (widget.product['isDeleted'] ?? false) ? Colors.red : Colors.green),
    ]);
  }

  Widget _buildTechnicalDetailsCard() {
    return _buildInfoCard('Technical Details', Icons.build_rounded, [_buildChipSection('Tech Stack', widget.product['techStack'])]);
  }

  Widget _buildLinksCard() {
    return _buildInfoCard('Links', Icons.link_rounded, [_buildLinksSection(widget.product['links'])]);
  }

  Widget _buildAdditionalInfoCard() {
    return _buildInfoCard('Additional Information', Icons.description_rounded, [
      _buildInfoRow('Description', widget.product['description'], Icons.notes),
      _buildInfoRow('Created At', widget.product['createdAt'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(widget.product['createdAt']).toLocal()) : null, Icons.calendar_today),
      _buildInfoRow('Updated At', widget.product['updatedAt'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(widget.product['updatedAt']).toLocal()) : null, Icons.update),
      if (widget.product['deletedAt'] != null && widget.product['deletedAt'].toString().isNotEmpty)
        _buildInfoRow('Deleted At', DateFormat('MMM d, yyyy').format(DateTime.parse(widget.product['deletedAt']).toLocal()), Icons.delete_forever, valueColor: Colors.red),
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

  Widget _buildLinksSection(List<dynamic>? links) {
    if (links == null || links.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Links',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600], letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          ...links.map((link) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  if (link['linkUrl'] != null && link['linkUrl'].toString().isNotEmpty) {
                    helper.launchURL(link['linkUrl']);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.link, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          link['linkTitle']?.toString() ?? 'Link',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
