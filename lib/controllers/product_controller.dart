import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductController extends GetxController {
  final ApiService _api = ApiService();
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  final RxList<ProductModel> newProducts = <ProductModel>[].obs;
  final RxList<ProductModel> adminProducts = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'Hotu'.obs;
  final RxString searchQuery = ''.obs;

  final List<String> categories = [
    'Hotu',
    'Sapatu',
    'Topu',
    'Kalsa',
    'Vestidu',
    'Bolsa',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final res = await _api.get('/products/');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> results = data is Map ? (data['results'] ?? []) : data;
        allProducts.value = results.map((e) => ProductModel.fromJson(e)).toList();
        _refreshDerivedLists();
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductsForAdmin() async {
    try {
      final res = await _api.get('/products/?admin=true');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> results = data is Map ? (data['results'] ?? []) : data;
        adminProducts.value = results.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching products for admin: $e');
    }
  }

  void _refreshDerivedLists() {
    featuredProducts.value = allProducts.where((p) => p.hasDiscount).toList();
    newProducts.value = allProducts;
  }

  List<ProductModel> get filteredProducts {
    List<ProductModel> products = allProducts;
    if (selectedCategory.value != 'Hotu') {
      products = products.where((p) => p.category == selectedCategory.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }
    return products;
  }

  void setCategory(String category) => selectedCategory.value = category;
  void setSearchQuery(String query) => searchQuery.value = query;
}
