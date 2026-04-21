import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_item_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Obx(() {
          if (cartController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartController.cartItems.isEmpty) {
            return const Center(child: Text('Karréta seidauk iha'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Karréta Hau',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D))),
                    const SizedBox(height: 4),
                    Text('${cartController.itemCount} itens',
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF888888))),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartController.cartItems.length,
                  itemBuilder: (context, index) =>
                      CartItemCard(item: cartController.cartItems[index]),
                ),
              ),
              _CartTotal(),
              _CheckoutButton(),
              const SizedBox(height: 12),
            ],
          );
        }),
      ),
    );
  }
}

class _CartTotal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal',
                  style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
              Obx(() => Text(
                  '\$${cartController.totalPrice.value.toStringAsFixed(2)}',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF888888)))),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ombak',
                    style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
                Text('Gratis',
                    style: TextStyle(fontSize: 11, color: Color(0xFF888888)))
              ]),
          const Divider(height: 20, thickness: 0.5, color: Color(0xFFEEEEEE)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Totál',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D))),
              Obx(() => Text(
                  '\$${cartController.totalPrice.value.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D)))),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () => Get.toNamed('/checkout'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(10)),
          child: const Center(
              child: Text('Checkout →',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white))),
        ),
      ),
    );
  }
}
