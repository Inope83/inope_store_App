import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../controllers/cart_controller.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: const BoxDecoration(color: Color(0xFFF0F0F0), borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
            child: Center(child: Text(product.imageUrl, style: const TextStyle(fontSize: 34))),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF2D2D2D))),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (product.hasDiscount) ...[
                      Text('\$${product.discountPrice}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
                      Text('\$${product.price}', style: const TextStyle(fontSize: 9, decoration: TextDecoration.lineThrough, color: Color(0xFF888888))),
                    ] else ...[
                      Text('\$${product.price}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
                    ],
                    GestureDetector(
                      onTap: () => cartController.addToCart(
                        productId: product.id,
                        name: product.name,
                        price: product.finalPrice,
                        size: 'M',
                        color: 'Black',
                        imageUrl: product.imageUrl,
                      ),
                      child: Container(
                        width: 24, height: 24,
                        decoration: const BoxDecoration(color: Color(0xFF2D2D2D), shape: BoxShape.circle),
                        child: const Center(child: Text('+', style: TextStyle(fontSize: 14, color: Colors.white))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
