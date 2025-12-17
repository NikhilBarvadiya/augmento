import 'package:augmento/utils/toaster.dart';
import 'package:augmento/views/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DigitalProductsCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  var products = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs, hasMore = true.obs;
  var page = 1.obs;
  var searchQuery = ''.obs;
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final techStackCtrl = TextEditingController();
  final linkTitleCtrl = TextEditingController();
  final linkUrlCtrl = TextEditingController();
  var techStackList = <String>[].obs;
  var linksList = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    debounce(searchQuery, (_) => fetchProducts(reset: true), time: const Duration(milliseconds: 500));
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (reset) {
      page.value = 1;
      products.clear();
      hasMore.value = true;
    }
    if (!hasMore.value || isLoading.value) return;
    isLoading.value = true;
    try {
      final response = await _authService.digitalProducts({'page': page.value, 'limit': 10, 'search': searchQuery.value.trim()});
      if (response.isNotEmpty) {
        final newRequirements = List<Map<String, dynamic>>.from(response['docs'] ?? []);
        products.addAll(newRequirements);
        hasMore.value = response["hasNextPage"] == true;
        if (hasMore.value) {
          page.value = (response["nextPage"] ?? page.value + 1);
        }
      }
    } catch (e) {
      toaster.error('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProduct({String? productId}) async {
    if (!_validateForm()) return;
    isLoading.value = true;
    try {
      final productData = {'title': titleCtrl.text.trim(), 'description': descriptionCtrl.text.trim(), 'techStack': techStackList.toList(), 'links': linksList.toList()};
      if (productId != null && productId.isNotEmpty) {
        productData["id"] = productId;
      }
      final response = await _authService.createDigitalProduct(productData);
      if (response.isNotEmpty) {
        clearForm();
        if (productId != null && productId.isNotEmpty) {
          int index = products.indexWhere((e) => e["_id"] == productId);
          if (index != -1) {
            products[index] = response;
          }
        } else {
          products.insert(0, Map<String, dynamic>.from(response));
        }
        Get.close(1);
      }
    } catch (e) {
      toaster.error('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    isLoading.value = true;
    try {
      final response = await _authService.deleteProduct({'id': id});
      if (response == true) {
        products.removeWhere((e) => e["_id"] == id);
      }
    } catch (e) {
      toaster.error('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (titleCtrl.text.trim().isEmpty) {
      toaster.warning('Product title is required');
      return false;
    }
    if (descriptionCtrl.text.trim().isEmpty) {
      toaster.warning('Description is required');
      return false;
    }
    if (techStackList.isEmpty) {
      toaster.warning('At least one technology stack is required');
      return false;
    }
    if (linksList.isEmpty) {
      toaster.warning('At least one product link is required');
      return false;
    }
    for (var link in linksList) {
      if (link['linkTitle']?.trim().isEmpty ?? true) {
        toaster.warning('All links must have a title');
        return false;
      }
      if (link['linkUrl']?.trim().isEmpty ?? true) {
        toaster.warning('All links must have a valid URL (starting with http:// or https://)');
        return false;
      }
    }
    return true;
  }

  void clearForm() {
    titleCtrl.clear();
    descriptionCtrl.clear();
    techStackCtrl.clear();
    linkTitleCtrl.clear();
    linkUrlCtrl.clear();
    techStackList.clear();
    linksList.clear();
  }

  void populateForm(Map<String, dynamic> product) {
    titleCtrl.text = product['title'] ?? '';
    descriptionCtrl.text = product['description'] ?? '';
    techStackList.value = List<String>.from(product['techStack'] ?? []);
    linksList.value = List<Map<String, String>>.from((product['links'] ?? []).map((link) => {'linkTitle': link['linkTitle'].toString(), 'linkUrl': link['linkUrl'].toString()}));
  }
}
