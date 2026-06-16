import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utils/format_utils.dart';

class AdminController extends GetxController {
  final ApiService _api = ApiService();

  final RxInt productCount = 0.obs;
  final RxInt orderCount = 0.obs;
  final RxInt userCount = 0.obs;
  final RxInt pendingOrderCount = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;

  final RxList<Map<String, dynamic>> allOrders = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString orderFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _loadStats(),
        fetchAllOrders(),
        fetchAllUsers(),
        fetchCategories(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      final res = await _api.get('/categories/');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> results = data is Map ? (data['results'] ?? []) : data;
        categories.value =
            results.map((c) => c as Map<String, dynamic>).toList();
      } else {
        Get.snackbar('Error', 'La konsege load kategoria: Status ${res.statusCode}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'La konsege load kategoria: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> addCategory(String name) async {
    try {
      final res = await _api.post('/categories/', body: {'name': name});
      if (res.statusCode == 201) {
        await fetchCategories();
        Get.snackbar('Suksesu', 'Kategoria foun hatama ona',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'La konsege hatama kategoria: Status ${res.statusCode}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'La konsege hatama kategoria: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> deleteCategory(dynamic id) async {
    try {
      final res = await _api.delete('/categories/$id/');
      if (res.statusCode == 204) {
        await fetchCategories();
        Get.snackbar('Suksesu', 'Kategoria hamos ona',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'La konsege hamos kategoria: Status ${res.statusCode}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'La konsege hamos kategoria: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> _loadStats() async {
    try {
      final res = await _api.get('/admin/stats/');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        productCount.value = data['product_count'] ?? 0;
        orderCount.value = data['order_count'] ?? 0;
        userCount.value = data['user_count'] ?? 0;
        pendingOrderCount.value = data['pending_order_count'] ?? 0;
        totalRevenue.value = FormatUtils.parseDouble(data['total_revenue']);
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      Get.snackbar('Avisu', 'La konsege karga estatístika',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
    }
  }

  Future<void> fetchAllOrders() async {
    try {
      final res = await _api.get('/admin/orders/');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> results = data is Map ? (data['results'] ?? []) : data;
        allOrders.value = results.map((o) => o as Map<String, dynamic>).toList();
      } else {
        Get.snackbar('Error', 'La konsege load orden: Status ${res.statusCode}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'La konsege load orden: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> fetchAllUsers() async {
    try {
      final res = await _api.get('/admin/users/');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> results = data is Map ? (data['results'] ?? []) : data;
        allUsers.value = results.map((u) => u as Map<String, dynamic>).toList();
      } else {
        Get.snackbar('Error', 'La konsege load uzuáriu: Status ${res.statusCode}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'La konsege load uzuáriu: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  List<Map<String, dynamic>> get filteredOrders {
    if (orderFilter.value == 'all') return allOrders;
    return allOrders
        .where((o) =>
            (o['status'] as String? ?? 'pending') == orderFilter.value)
        .toList();
  }

  String? userNameFor(dynamic userId) {
    if (userId == null) return null;
    final id = userId.toString();
    final user = allUsers.firstWhereOrNull((u) => u['id'].toString() == id);
    return user?['name'] as String? ?? user?['email'] as String?;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final res = await _api.put('/admin/orders/$orderId/status/', body: {'status': status});
      if (res.statusCode == 200) {
        await Future.wait([fetchAllOrders(), _loadStats()]);
        Get.snackbar('Suksesu',
            status == 'finished'
                ? 'Orden marka ona kompleta'
                : 'Status orden atualiza ona',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'La konsege atualiza orden: Status ${res.statusCode}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'La konsege atualiza orden: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}
