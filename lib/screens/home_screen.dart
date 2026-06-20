import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductController _productController = Get.find();
  final CartController _cartController = Get.find();
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _productController.fetchProducts(),
          color: const Color(0xFF1A1A1A),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildAppBar()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildBannerSlider()),
            SliverToBoxAdapter(
              child: _buildSectionHeader('Kategoria', onTap: () => Get.toNamed('/shop')),
            ),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'Produtu Foun',
                onTap: () => Get.toNamed('/shop'),
              ),
            ),
            // New Products Grid
            Obx(() {
              if (_productController.isLoading.value) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                );
              }
              final products = _productController.homeFilteredNewProducts;
              if (products.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'Seidauk iha produtu',
                        style: TextStyle(color: Color(0xFF888888)),
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ProductCard(
                      product: products[index],
                      onAddToCart: () => _cartController.addToCart(
                        productId: products[index].id.toString(),
                        name: products[index].name,
                        price: products[index].price,
                        imageUrl: products[index].firstImage,
                      ),
                    ),
                    childCount: products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                ),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ola 👋',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 2),
              Obx(
                () => Text(
                  _authController.currentUser.value?.name ?? 'Visitante',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _AppBarButton(
                icon: Icons.notifications_outlined,
                dark: false,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _AppBarButton(
                icon: Icons.shopping_bag_outlined,
                dark: true,
                badgeWidget: _CartBadge(controller: _cartController),
                onTap: () => Get.toNamed('/cart'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: GestureDetector(
        onTap: () => Get.toNamed('/shop'),
        child: Container(
          height: 50,
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
              const Expanded(
                child: Text(
                  'Buka produtu fashion...',
                  style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(7),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSlider() {
    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              'Haree Hotu →',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _productController.categories.map((cat) {
          return _CategoryChip(
            label: cat,
            controller: _productController,
          );
        }).toList(),
      ),
    ));
  }
}

// ── Category Chip ─────────────────────────────────────────────────
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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

// ── Cart Badge ───────────────────────────────────────────────────
class _CartBadge extends StatelessWidget {
  final CartController controller;
  const _CartBadge({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.itemCount <= 0) return const SizedBox.shrink();
      return Container(
        width: 15,
        height: 15,
        decoration: const BoxDecoration(
          color: Color(0xFFE53935),
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

// ── App bar button ───────────────────────────────────────────────
class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;
  final Widget? badgeWidget;

  const _AppBarButton({
    required this.icon,
    required this.dark,
    required this.onTap,
    this.badgeWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: dark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          if (badgeWidget != null)
            Positioned(top: 5, right: 5, child: badgeWidget!),
        ],
      ),
    );
  }
}

// ── Product Card ─────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const _ProductCard({required this.product, required this.onAddToCart});

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
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: product.firstImage.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
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
                            child: Icon(
                              Icons.shopping_bag,
                              size: 48,
                              color: Color(0xFFCCCCCC),
                            ),
                          ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFAAAAAA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
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
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
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
                          child: Icon(
                            product.stock > 0 ? Icons.add : Icons.block,
                            color: Colors.white,
                            size: 16,
                          ),
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

  String _fmt(double price) {
    final intPart = price.toInt();
    final formatted = intPart.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '\$$formatted';
  }
}
