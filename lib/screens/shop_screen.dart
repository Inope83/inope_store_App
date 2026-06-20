import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/product_model.dart';

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
                  itemBuilder: (_, i) => _ShopProductCard(
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
              _CartBadge(cartController: cartController),
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
              return _CategoryChip(
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

class _CartBadge extends StatelessWidget {
  final CartController cartController;
  const _CartBadge({required this.cartController});

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
            color: Color(0xFFE53935),
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final ProductController controller;
  const _CategoryChip({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = controller.selectedCategory.value == label;
      return GestureDetector(
        onTap: () => controller.selectedCategory.value = label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1A1A1A) : Colors.white,
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
              color: isActive ? Colors.white : const Color(0xFF555555),
            ),
          ),
        ),
      );
    });
  }
}

class _ShopProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const _ShopProductCard({required this.product, required this.onAddToCart});

  String _fmt(double price) {
    final intPart = price.toInt();
    final formatted = intPart.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '\$$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/product-detail', parameters: {'id': product.id.toString()}),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: product.firstImage.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              product.firstImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported,
                                color: Color(0xFFCCCCCC),
                                size: 40,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.shopping_bag, size: 48, color: Color(0xFFCCCCCC)),
                          ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (product.stock == 0)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: const Center(
                          child: Text(
                            'Stock\nMamuk',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (product.stock > 0 && product.stock <= 5)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Stok: ${product.stock}',
                          style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fmt(product.price),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                          ),
                          if (product.hasDiscount)
                            Text(
                              _fmt(product.originalPrice!),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFAAAAAA),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            'Stok: ${product.stock}',
                            style: TextStyle(
                              fontSize: 10,
                              color: product.stock <= 5
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: product.stock > 0 ? onAddToCart : null,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: product.stock > 0 ? const Color(0xFF1A1A1A) : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(product.stock > 0 ? Icons.add : Icons.block, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

