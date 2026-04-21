import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/cart_item.dart';
import 'auth_controller.dart';

class CartController extends GetxController {
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

  Future<void> fetchCart() async {
    if (_authController.userId.isEmpty) return;

    isLoading.value = true;
    try {
      Database db = await DatabaseHelper().database;
      List<Map<String, dynamic>> result = await db.query('cart',
          where: 'user_id = ?', whereArgs: [_authController.userId]);
      cartItems.value = result.map((e) => CartItemModel.fromJson(e)).toList();
      _calculateTotal();
    } catch (e) {
      print('Error fetching cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToCart({
    required String productId,
    required String name,
    required double price,
    required String size,
    required String color,
    required String imageUrl,
    int quantity = 1,
  }) async {
    if (_authController.userId.isEmpty) {
      Get.toNamed('/login');
      return;
    }

    isLoading.value = true;
    try {
      Database db = await DatabaseHelper().database;
      String id = DateTime.now().millisecondsSinceEpoch.toString();

      CartItemModel newItem = CartItemModel(
        id: id,
        productId: productId,
        userId: _authController.userId,
        name: name,
        price: price,
        quantity: quantity,
        size: size,
        color: color,
        imageUrl: imageUrl,
      );

      await db.insert('cart', newItem.toJson());
      await fetchCart();
      Get.snackbar('Suksesu', 'Adisiona iha karréta',
          snackPosition: SnackPosition.BOTTOM);
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
      Database db = await DatabaseHelper().database;
      await db.update('cart', {'quantity': newQuantity},
          where: 'id = ?', whereArgs: [itemId]);
      await fetchCart();
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      Database db = await DatabaseHelper().database;
      await db.delete('cart', where: 'id = ?', whereArgs: [itemId]);
      await fetchCart();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      Database db = await DatabaseHelper().database;
      await db.delete('cart',
          where: 'user_id = ?', whereArgs: [_authController.userId]);
      cartItems.clear();
      totalPrice.value = 0;
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  void _calculateTotal() {
    totalPrice.value = cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
}
