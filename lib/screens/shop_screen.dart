import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../widgets/category_chip.dart';
import '../widgets/cart_badge.dart';
import '../widgets/product_card.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find();
    final CartController cartController = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(cartController),
            _buildSearchBar(productController),
            _buildCategoryFilter(productController),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => productController.fetchProducts(),
                color: const Color(0xFF1A1A1A),
                child: Obx(() {
                  if (productController.isLoading.value) {
                    return const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF1A1A1A)),
                      ),
                    );
                  }
                  final products = productController.filteredProducts;
                  if (products.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: _emptyState,
                    );
                  }
                  return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) => ProductCard(
                    product: products[i],
                    onAddToCart: () => cartController.addToCart(
                      productId: products[i].id.toString(),
                      name: products[i].name,
                      price: products[i].price,
                      imageUrl: products[i].firstImage,
                    ),
                  ),
                );
              }),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(CartController cartController) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          const Text(
            'Shop',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              GestureDetector(
                onTap: () => Get.toNamed('/cart'),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              PositionedCartBadge(cartController: cartController),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ProductController productController) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, color: Color(0xFFAAAAAA), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (v) => productController.searchQuery.value = v,
                decoration: const InputDecoration(
                  hintText: 'Buka produtu...',
                  hintStyle: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(ProductController productController) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 38,
        child: Obx(
          () => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: productController.categories.length,
            itemBuilder: (_, i) {
              final cat = productController.categories[i];
              return CategoryChip(
                label: cat,
                controller: productController,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget get _emptyState => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              'Produtu la hetan',
              style: TextStyle(color: Color(0xFF888888), fontSize: 15),
            ),
          ],
        ),
      );
}



