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

  Future<List<dynamic>> _fetchAllPages(String path) async {
    final List<dynamic> allResults = [];
    String? nextUrl;
    final res = await _api.get(path);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List<dynamic> results = data is Map ? (data['results'] ?? []) : data;
      allResults.addAll(results);
      nextUrl = data is Map ? data['next'] as String? : null;
    }
    while (nextUrl != null) {
      final nextRes = await _api.get(nextUrl.replaceFirst(ApiService.baseUrl, ''));
      if (nextRes.statusCode == 200) {
        final data = jsonDecode(nextRes.body);
        allResults.addAll(data['results'] ?? []);
        nextUrl = data['next'] as String?;
      } else {
        break;
      }
    }
    return allResults;
  }

  Future<void> fetchCategories() async {
    try {
      final cats = await _fetchAllPages('/categories/');
      final names = cats.map((c) => c['name'] as String).toList();
      categories.value = ['Hotu', ...names];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final results = await _fetchAllPages('/products/');
      allProducts.value = results.map((e) => ProductModel.fromJson(e)).toList();
      _refreshDerivedLists();
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductsForAdmin() async {
    try {
      final results = await _fetchAllPages('/products/?admin=true');
      adminProducts.value = results.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching products for admin: $e');
    }
  }

  void _refreshDerivedLists() {
    featuredProducts.value = allProducts.where((p) => p.hasDiscount).toList();
    final sorted = List<ProductModel>.from(allProducts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    newProducts.value = sorted.where((p) => p.createdAt.isAfter(cutoff)).toList();
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

  List<ProductModel> get homeFilteredNewProducts {
    if (selectedCategory.value == 'Hotu') return newProducts;
    return newProducts
        .where((p) => p.category == selectedCategory.value)
        .toList();
  }

  void setCategory(String category) => selectedCategory.value = category;
  void setSearchQuery(String query) => searchQuery.value = query;

  ProductModel? getProductById(String id) {
    for (final p in allProducts) {
      if (p.id.toString() == id) return p;
    }
    return null;
  }
}
