import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: const Text('SHOP',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D))),
            ),
            const SearchBarWidget(),
            const _FilterRow(),
            Expanded(
              child: Obx(() {
                if (productController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (productController.filteredProducts.isEmpty) {
                  return const Center(child: Text('La hetan produtu'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: productController.filteredProducts.length,
                  itemBuilder: (context, index) => ProductCard(
                      product: productController.filteredProducts[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Obx(() => Row(
            children: productController.categories.map((category) {
              bool isActive =
                  productController.selectedCategory.value == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => productController.setCategory(category),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF2D2D2D) : Colors.white,
                      border: isActive
                          ? null
                          : Border.all(
                              color: const Color(0xFFE0E0E0), width: 0.5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(category,
                        style: TextStyle(
                            fontSize: 11,
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF888888))),
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }
}
