import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';

class OrderController extends GetxController {
  final ApiService _api = ApiService();
  final AuthController _authController = Get.find();
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_authController.currentUser, (user) {
      if (user != null) fetchOrders();
    });
  }

  Future<void> fetchOrders() async {
    if (!_authController.isLoggedIn) return;

    isLoading.value = true;
    try {
      final res = await _api.get('/orders/');
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        orders.value = data.map((e) => OrderModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createOrder({
    required String paymentMethod,
    required String address,
    String phone = '',
    String email = '',
  }) async {
    if (Get.find<CartController>().cartItems.isEmpty) {
      Get.snackbar('Sala', 'Kareta seidauk iha');
      return false;
    }

    isLoading.value = true;
    try {
      final res = await _api.post('/orders/create/', body: {
        'address': address,
        'phone': phone,
        'email': email,
        'payment_method': paymentMethod,
      });
      if (res.statusCode == 201) {
        await Get.find<CartController>().clearCart();
        await fetchOrders();
        Get.snackbar('Suksesu', 'Orde halo ho suksesu');
        return true;
      }
      String err;
      try {
        final body = jsonDecode(res.body);
        err = body is Map ? (body['error'] ?? 'Falha atu halo orde').toString() : 'Falha atu halo orde';
      } catch (_) {
        err = 'Falha atu halo orde';
      }
      Get.snackbar('Sala', err);
      return false;
    } catch (e) {
      Get.snackbar('Sala', 'Falha atu halo orde');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
