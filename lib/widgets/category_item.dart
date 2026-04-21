import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';

class CategoryItem extends StatelessWidget {
  final String category;
  final bool isActive;
  const CategoryItem(
      {super.key, required this.category, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find();

    return GestureDetector(
      onTap: () => productController.setCategory(category),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF2D2D2D) : Colors.white,
              border: isActive
                  ? null
                  : Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getCategoryIcon(category),
                size: 22,
                color: isActive ? Colors.white : const Color(0xFF2D2D2D)),
          ),
          const SizedBox(height: 5),
          Text(category,
              style: TextStyle(
                  fontSize: 10,
                  color: isActive
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFF888888),
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal)),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Sapatu':
        return Icons.sports_basketball;
      case 'Topu':
        return Icons.checkroom;
      case 'Kalsa':
        return Icons.shopping_bag;
      case 'Vestidu':
        return Icons.woman;
      case 'Bolsa':
        return Icons.shopping_bag;
      default:
        return Icons.grid_view;
    }
  }
}
