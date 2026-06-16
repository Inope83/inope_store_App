import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/cart_model.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class CartController extends GetxController {
  final ApiService _api = ApiService();
  final AuthController _authController = Get.find();
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble totalPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_authController.currentUser, (user) {
      if (user != null) fetchCart();
    });
  }

  List<CartItemModel> get items => cartItems;

  Future<void> fetchCart() async {
    if (!_authController.isLoggedIn) return;

    isLoading.value = true;
    try {
      final res = await _api.get('/cart/');
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        cartItems.value = data.map((e) => CartItemModel.fromJson(e)).toList();
        _calculateTotal();
      }
    } catch (e) {
      debugPrint('Error fetching cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToCart({
    required String productId,
    required String name,
    required double price,
    String size = '',
    String color = '',
    required String imageUrl,
    int quantity = 1,
  }) async {
    if (!_authController.isLoggedIn) {
      Get.toNamed('/login');
      return;
    }

    isLoading.value = true;
    try {
      final res = await _api.post('/cart/add/', body: {
        'product_id': productId,
        'product_name': name,
        'product_image': imageUrl,
        'price': price.toString(),
      });
      if (res.statusCode == 201 || res.statusCode == 200) {
        await fetchCart();
        Get.snackbar('Suksesu', 'Adisiona iha karréta',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Sala', 'Falha atu adisiona iha karréta',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(itemId);
      return;
    }

    try {
      final id = int.tryParse(itemId) ?? 0;
      final res = await _api.put('/cart/item/$id/', body: {
        'quantity': newQuantity,
      });
      if (res.statusCode == 200) {
        await fetchCart();
      }
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      final id = int.tryParse(itemId) ?? 0;
      await _api.delete('/cart/item/$id/');
      await fetchCart();
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _api.delete('/cart/clear/');
      cartItems.clear();
      totalPrice.value = 0;
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }

  void _calculateTotal() {
    totalPrice.value = cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
}
