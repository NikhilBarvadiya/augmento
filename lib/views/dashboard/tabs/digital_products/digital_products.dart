import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/digital_products/digital_products_ctrl.dart';
import 'package:augmento/views/dashboard/tabs/digital_products/ui/digital_product_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DigitalProducts extends StatelessWidget {
  const DigitalProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DigitalProductsCtrl>(
      init: DigitalProductsCtrl(),
      builder: (ctrl) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchBar(ctrl),
            Expanded(child: _buildProductsList(ctrl)),
          ],
        ),
        floatingActionButton: _buildFAB(context, ctrl),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Digital Products', style: TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: decoration.colorScheme.primary,
      foregroundColor: decoration.colorScheme.onPrimary,
    );
  }

  Widget _buildSearchBar(DigitalProductsCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Container(
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) => ctrl.searchQuery.value = value,
        ),
      ),
    );
  }

  Widget _buildProductsList(DigitalProductsCtrl ctrl) {
    return RefreshIndicator(
      onRefresh: () => ctrl.fetchProducts(reset: true),
      child: Obx(() {
        if (ctrl.isLoading.value && ctrl.products.isEmpty) {
          return _buildShimmerList();
        }
        if (ctrl.products.isEmpty) {
          return _buildEmptyState();
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!ctrl.isLoading.value && ctrl.hasMore.value && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
              ctrl.fetchProducts();
            }
            return false;
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: ctrl.products.length + (ctrl.hasMore.value ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index < ctrl.products.length) {
                return _buildProductCard(context, ctrl, ctrl.products[index]);
              } else {
                return _buildLoadMoreIndicator();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(padding: const EdgeInsets.all(16), itemCount: 6, separatorBuilder: (context, index) => const SizedBox(height: 12), itemBuilder: (context, index) => _buildShimmerCard());
  }

  Widget _buildShimmerCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildShimmerContainer(50, 50, isCircular: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildShimmerContainer(120, 16), const SizedBox(height: 8), _buildShimmerContainer(80, 14)]),
                ),
                _buildShimmerContainer(24, 24),
              ],
            ),
            const SizedBox(height: 12),
            _buildShimmerContainer(double.infinity, 14),
            const SizedBox(height: 8),
            Row(children: [_buildShimmerContainer(60, 20, borderRadius: 10), const SizedBox(width: 8), _buildShimmerContainer(80, 20, borderRadius: 10)]),
          ],
        ),
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
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text('Create your first digital product', style: TextStyle(color: Colors.grey[500])),
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

  Widget _buildProductCard(BuildContext context, DigitalProductsCtrl ctrl, Map<String, dynamic> product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailsDialog(context, product),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(ctrl, product),
              const SizedBox(height: 12),
              _buildDescription(product),
              const SizedBox(height: 12),
              _buildTechStackSection(product),
              const SizedBox(height: 12),
              _buildLinksSection(product),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(DigitalProductsCtrl ctrl, Map<String, dynamic> product) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.inventory_2, color: decoration.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product['title'] ?? 'Unknown Product', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                'Created: ${product['createdAt'] != null ? DateTime.parse(product['createdAt']).toLocal().toString().split('.')[0] : 'N/A'}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        _buildActionMenu(ctrl, product),
      ],
    );
  }

  Widget _buildActionMenu(DigitalProductsCtrl ctrl, Map<String, dynamic> product) {
    return PopupMenuButton<String>(
      color: Colors.white,
      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) => _handleMenuAction(value, ctrl, product),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(Map<String, dynamic> product) {
    return Text(
      product['description'] ?? 'No description',
      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTechStackSection(Map<String, dynamic> product) {
    final techStack = product['techStack'] as List?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tech Stack',
          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        techStack != null && techStack.isNotEmpty
            ? Wrap(
                spacing: 6,
                runSpacing: 4,
                children: techStack.take(3).map((tech) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(tech.toString(), style: TextStyle(fontSize: 11, color: Colors.blue[700])),
                  );
                }).toList(),
              )
            : Text('No tech stack specified', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildLinksSection(Map<String, dynamic> product) {
    final links = product['links'] as List?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Links',
          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        links != null && links.isNotEmpty
            ? Wrap(
                spacing: 6,
                runSpacing: 4,
                children: links.take(2).map((link) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(link['linkTitle']?.toString() ?? 'Link', style: TextStyle(fontSize: 11, color: Colors.green[700])),
                  );
                }).toList(),
              )
            : Text('No links specified', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  void _handleMenuAction(String action, DigitalProductsCtrl ctrl, Map<String, dynamic> product) {
    switch (action) {
      case 'edit':
        ctrl.clearForm();
        Get.to(() => DigitalProductForm(product: product, isEdit: true));
        break;
      case 'delete':
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.delete, color: Color(0xFFEF4444)),
                SizedBox(width: 8),
                Text('Delete Product'),
              ],
            ),
            content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  ctrl.deleteProduct(product['_id']);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        break;
    }
  }

  Widget _buildFAB(BuildContext context, DigitalProductsCtrl ctrl) {
    return FloatingActionButton.extended(
      onPressed: () {
        ctrl.clearForm();
        Get.to(() => const DigitalProductForm());
      },
      icon: const Icon(Icons.add),
      label: const Text('Add Product'),
      foregroundColor: Colors.white,
      backgroundColor: decoration.colorScheme.primary,
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        backgroundColor: Colors.white,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85, maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: decoration.colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.inventory_2, size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        product['title'] ?? 'Unknown',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: decoration.colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Product Details'),
                      _buildDetailRow('Title', product['title']),
                      _buildDetailRow('Description', product['description']),
                      _buildChipRow('Tech Stack', product['techStack']),
                      _buildLinkRow('Links', product['links']),
                      _buildDetailRow('Created At', product['createdAt'] != null ? DateTime.parse(product['createdAt']).toLocal().toString().split('.')[0] : 'N/A'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: decoration.colorScheme.primary,
                        foregroundColor: decoration.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: decoration.colorScheme.primary),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow(String label, List<dynamic>? items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: items == null || items.isEmpty
                ? const Text('N/A', style: TextStyle(fontSize: 14, color: Colors.black87))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: items
                        .map(
                          (item) => Chip(
                            label: Text(item.toString(), style: TextStyle(fontSize: 12, color: decoration.colorScheme.primary)),
                            backgroundColor: decoration.colorScheme.secondaryContainer,
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(String label, List<dynamic>? links) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: links == null || links.isEmpty
                ? const Text('N/A', style: TextStyle(fontSize: 14, color: Colors.black87))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: links
                        .map(
                          (link) => Chip(
                            label: Text(link['linkTitle'].toString(), style: TextStyle(fontSize: 12, color: decoration.colorScheme.primary)),
                            backgroundColor: decoration.colorScheme.secondaryContainer,
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
