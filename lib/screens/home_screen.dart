import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/category_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find();
    final CartController cartController = Get.find();
    final AuthController authController = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ola 👋',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF888888))),
                            const SizedBox(height: 2),
                            Text(
                              authController.currentUser.value?.name ?? 'Visitor',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2D2D2D)),
                            ),
                          ],
                        )),
                    Obx(() => Stack(
                          children: [
                            const Icon(Icons.shopping_bag_outlined,
                                size: 22, color: Color(0xFF2D2D2D)),
                            if (cartController.itemCount > 0)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFE53935),
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Text('${cartController.itemCount}',
                                        style: const TextStyle(
                                            fontSize: 8, color: Colors.white)),
                                  ),
                                ),
                              ),
                          ],
                        )),
                  ],
                ),
              ),
              const SearchBarWidget(),
              _buildBanner(),
              const CategoriesSection(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Produtu Foun',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D2D2D))),
                    Text('Haree Hotu',
                        style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
                  ],
                ),
              ),
              Obx(() {
                if (productController.newProducts.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                          child: ProductCard(
                              product: productController.newProducts[0])),
                      const SizedBox(width: 12),
                      if (productController.newProducts.length > 1)
                        Expanded(
                            child: ProductCard(
                                product: productController.newProducts[1])),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF2D2D2D), Color(0xFF4A4A4A)]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(3)),
                  child: const Text('DESKONTU 30% OFF',
                      style: TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 6),
                const Text('Koleksaun Estasaun\nFoun',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
                const SizedBox(height: 6),
                const Text('Hola Agora →',
                    style: TextStyle(fontSize: 9, color: Color(0xFFE8DDD4))),
              ],
            ),
            const Icon(Icons.shopping_bag, size: 32, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kategoria',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D))),
              Text('Haree Hotu',
                  style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Obx(() => Row(
            children: productController.categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CategoryItem(
                    category: category,
                    isActive:
                        productController.selectedCategory.value == category),
              );
            }).toList(),
          )),
        ),
      ],
    );
  }
}
