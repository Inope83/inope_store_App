import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/order.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';

class OrderController extends GetxController {
  final AuthController _authController = Get.find();
  final CartController _cartController = Get.find();
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
    if (_authController.userId.isEmpty) return;

    isLoading.value = true;
    try {
      Database db = await DatabaseHelper().database;
      List<Map<String, dynamic>> result = await db.query('orders',
          where: 'user_id = ?', whereArgs: [_authController.userId]);
      orders.value = result.map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createOrder({
    required String paymentMethod,
    required String address,
  }) async {
    if (_cartController.cartItems.isEmpty) {
      Get.snackbar('Sala', 'Kareta seidauk iha');
      return false;
    }

    isLoading.value = true;
    try {
      Database db = await DatabaseHelper().database;
      String id = DateTime.now().millisecondsSinceEpoch.toString();

      OrderModel newOrder = OrderModel(
        id: id,
        userId: _authController.userId,
        totalAmount: _cartController.totalPrice.value,
        status: 'pending',
        paymentMethod: paymentMethod,
        address: address,
        createdAt: DateTime.now(),
      );

      await db.insert('orders', newOrder.toJson());
      await _cartController.clearCart();

      Get.snackbar('Suksesu', 'Orde halo ho suksesu');
      return true;
    } catch (e) {
      Get.snackbar('Sala', 'Falha atu halo orde');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
