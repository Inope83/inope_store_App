import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../controllers/cart_controller.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5)),
      child: Row(
        children: [
          Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Text(item.imageUrl,
                      style: const TextStyle(fontSize: 26)))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D2D2D))),
                const SizedBox(height: 2),
                Text('Tamanhu: ${item.size} · ${item.color}',
                    style:
                        const TextStyle(fontSize: 9, color: Color(0xFFAAAAAA))),
                const SizedBox(height: 4),
                Text('\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D2D2D))),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () =>
                    cartController.updateQuantity(item.id, item.quantity - 1),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF0F0F0), shape: BoxShape.circle),
                  child: const Center(
                      child: Text('-',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xFF2D2D2D)))),
                ),
              ),
              const SizedBox(width: 10),
              Text('${item.quantity}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D))),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () =>
                    cartController.updateQuantity(item.id, item.quantity + 1),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF0F0F0), shape: BoxShape.circle),
                  child: const Center(
                      child: Text('+',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xFF2D2D2D)))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
