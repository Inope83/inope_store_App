import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../utils/app_colors.dart';

class CartBadge extends StatelessWidget {
  final CartController controller;
  const CartBadge({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.itemCount <= 0) return const SizedBox.shrink();
      return Container(
        width: 15,
        height: 15,
        decoration: const BoxDecoration(
          color: AppColors.red,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${controller.itemCount}',
            style: const TextStyle(
              fontSize: 8,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }
}

class PositionedCartBadge extends StatelessWidget {
  final CartController cartController;
  const PositionedCartBadge({super.key, required this.cartController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (cartController.itemCount <= 0) return const SizedBox.shrink();
      return Positioned(
        top: 5,
        right: 5,
        child: Container(
          width: 15,
          height: 15,
          decoration: const BoxDecoration(
            color: AppColors.red,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${cartController.itemCount}',
              style: const TextStyle(
                fontSize: 8,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    });
  }
}
