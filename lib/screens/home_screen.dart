import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/notification_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/category_chip.dart';
import '../widgets/cart_badge.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductController _productController = Get.find();
  final CartController _cartController = Get.find();
  final AuthController _authController = Get.find();
  final NotificationController _notificationController = Get.find();

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
                    (context, index) => ProductCard(
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

  void _showNotifications() {
    _notificationController.markAllRead();
    final notifs = _notificationController.notifications;
    if (notifs.isEmpty) {
      Get.snackbar('Notifikasaun', 'Seidauk iha notifikasaun foun',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notifikasaun',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    _notificationController.clearNotifications();
                    Get.back();
                  },
                  child: const Text('Hamos Hotu'),
                ),
              ],
            ),
            const Divider(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: notifs.length,
                itemBuilder: (_, i) {
                  final n = notifs[i];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.check_circle, color: Colors.green, size: 22),
                    ),
                    title: Text(n['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(n['message'] ?? '',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                    onTap: () {
                      Get.back();
                      final productId = n['productId'] ?? '';
                      if (productId.isNotEmpty) {
                        Get.toNamed('/product-detail', parameters: {'id': productId});
                      }
                    },
                  );
                },
              ),
            ),
          ],
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
              Obx(() => _AppBarButton(
                icon: Icons.notifications_outlined,
                dark: false,
                badgeWidget: _notificationController.hasUnread.value
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
                onTap: () => _showNotifications(),
              )),
              const SizedBox(width: 10),
              _AppBarButton(
                icon: Icons.shopping_bag_outlined,
                dark: true,
                badgeWidget: CartBadge(controller: _cartController),
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
          return CategoryChip(
            label: cat,
            controller: _productController,
          );
        }).toList(),
      ),
    ));
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


