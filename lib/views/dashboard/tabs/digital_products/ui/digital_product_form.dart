import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/digital_products/digital_products_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class DigitalProductForm extends StatelessWidget {
  final Map<String, dynamic>? product;
  final bool isEdit;

  const DigitalProductForm({super.key, this.product, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DigitalProductsCtrl>(
      builder: (ctrl) {
        if (isEdit && product != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ctrl.populateForm(product!);
          });
        }
        return KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: _buildAppBar(),
              body: _buildBody(context, ctrl),
              bottomNavigationBar: !isKeyboardVisible ? _buildBottomBar(context, ctrl) : const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(isEdit ? 'Edit Product' : 'Add New Product', style: const TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: decoration.colorScheme.primary,
      foregroundColor: decoration.colorScheme.onPrimary,
    );
  }

  Widget _buildBody(BuildContext context, DigitalProductsCtrl ctrl) {
    return SingleChildScrollView(child: Column(children: [_buildBasicInfoSection(ctrl), _buildTechStackSection(ctrl), _buildLinksSection(ctrl), const SizedBox(height: 100)]));
  }

  Widget _buildBasicInfoSection(DigitalProductsCtrl ctrl) {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        _buildFormField(controller: ctrl.titleCtrl, label: 'Product Title', icon: Icons.title, isRequired: true),
        _buildFormField(controller: ctrl.descriptionCtrl, label: 'Description', icon: Icons.description, maxLines: 3, isRequired: true),
      ],
    );
  }

  Widget _buildTechStackSection(DigitalProductsCtrl ctrl) {
    return _buildSection(
      title: 'Tech Stack',
      icon: Icons.code,
      children: [
        _buildMultiSelectField(
          txtController: ctrl.techStackCtrl,
          ctrl: ctrl,
          fieldType: 'techStack',
          label: 'Technologies',
          icon: Icons.computer,
          hint: 'Add technologies (e.g., React, Node.js)',
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildLinksSection(DigitalProductsCtrl ctrl) {
    return _buildSection(
      title: 'Product Links',
      icon: Icons.link,
      children: [
        _buildLinkInputFields(ctrl),
        const SizedBox(height: 8),
        Obx(
          () => ctrl.linksList.isEmpty
              ? Center(
                  child: Text('No links added', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: ctrl.linksList.map((link) {
                    return Chip(
                      label: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(link['linkTitle'] ?? 'Link', style: TextStyle(fontSize: 14, color: Colors.green[800])),
                          Text(link['linkUrl'] ?? 'Link-URL', style: TextStyle(fontSize: 12, color: Colors.green[800])),
                        ],
                      ),
                      onDeleted: () => ctrl.linksList.remove(link),
                      backgroundColor: Colors.green[50],
                      deleteIconColor: Colors.green[700],
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildLinkInputFields(DigitalProductsCtrl ctrl) {
    return Column(
      children: [
        _buildFormField(controller: ctrl.linkTitleCtrl, label: 'Link Title', icon: Icons.label, hint: 'e.g., GitHub, Demo', isRequired: true),
        _buildFormField(controller: ctrl.linkUrlCtrl, label: 'Link URL', icon: Icons.link, hint: 'e.g., https://github.com/project', isRequired: true),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              if (ctrl.linkTitleCtrl.text.trim().isNotEmpty && ctrl.linkUrlCtrl.text.trim().isNotEmpty) {
                ctrl.linksList.add({'linkTitle': ctrl.linkTitleCtrl.text.trim(), 'linkUrl': ctrl.linkUrlCtrl.text.trim()});
                ctrl.linkTitleCtrl.clear();
                ctrl.linkUrlCtrl.clear();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Link'),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 20, color: decoration.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormField({required TextEditingController controller, required String label, required IconData icon, String? hint, bool isRequired = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        minLines: 1,
        maxLines: maxLines,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: '$label${isRequired ? ' *' : ''}',
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: decoration.colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color:  Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildMultiSelectField({
    required TextEditingController txtController,
    required DigitalProductsCtrl ctrl,
    required String fieldType,
    required String label,
    required IconData icon,
    required String hint,
    bool isRequired = false,
  }) {
    RxList<String> items = ctrl.techStackList;
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label${isRequired ? ' *' : ''}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color:  Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  items.isEmpty
                      ? Text(hint, style: TextStyle(color: Colors.grey[600], fontSize: 14))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: items.map((item) {
                            return Chip(
                              label: Text(item, style: TextStyle(fontSize: 12, color: Colors.blue[800])),
                              onDeleted: () => ctrl.techStackList.remove(item),
                              backgroundColor: Colors.blue[100],
                              deleteIconColor: Colors.blue[700],
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: txtController,
                          decoration: InputDecoration(
                            hintText: 'Type and press Enter to add',
                            hintStyle: TextStyle(fontSize: 12, letterSpacing: .5),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            prefixIcon: Icon(icon, size: 20),
                            suffixIcon: IconButton(
                              onPressed: () {
                                if (txtController.text.trim().isNotEmpty) {
                                  if (!ctrl.techStackList.contains(txtController.text.trim())) {
                                    ctrl.techStackList.add(txtController.text.trim());
                                  }
                                  txtController.clear();
                                }
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty && !ctrl.techStackList.contains(value.trim())) {
                              ctrl.techStackList.add(value.trim());
                              txtController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomBar(BuildContext context, DigitalProductsCtrl ctrl) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.close(1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Obx(
                () => ElevatedButton(
                  onPressed: ctrl.isLoading.value
                      ? null
                      : () async {
                          await ctrl.createProduct(productId: isEdit ? product!['_id'] : null);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: decoration.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: ctrl.isLoading.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          isEdit ? 'Update Product' : 'Create Product',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
