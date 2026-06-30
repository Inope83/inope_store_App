import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../utils/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final ProductController controller;
  const CategoryChip({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = controller.selectedCategory.value == label;
      return GestureDetector(
        onTap: () => controller.selectedCategory.value = label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.dark : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.white : AppColors.textLight,
            ),
          ),
        ),
      );
    });
  }
}
