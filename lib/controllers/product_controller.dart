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
  final RxList<String> categories = <String>['Hotu'].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final res = await _api.get('/categories/');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> results = data is Map ? (data['results'] ?? []) : data;
        final names = results.map((c) => c['name'] as String).toList();
        categories.value = ['Hotu', ...names];
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
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
    final sorted = List<ProductModel>.from(allProducts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    newProducts.value = sorted;
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
