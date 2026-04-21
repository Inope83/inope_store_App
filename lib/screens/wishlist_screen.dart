import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wishlist_controller.dart';
import '../controllers/product_controller.dart';
import '../screens/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WishlistController wishlistController = Get.find();
    final ProductController productController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (wishlistController.wishlistItems.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Color(0xFFCCCCCC)),
                SizedBox(height: 16),
                Text('Wishlist seidauk iha',
                    style: TextStyle(fontSize: 16, color: Color(0xFF888888))),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: wishlistController.wishlistItems.length,
          itemBuilder: (context, index) {
            final item = wishlistController.wishlistItems[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Text(item.imageUrl, style: const TextStyle(fontSize: 40)),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('\$${item.finalPrice}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => wishlistController.removeFromWishlist(item.productId),
                ),
                onTap: () {
                  final product = productController.products.firstWhere(
                    (p) => p.id == item.productId,
                    orElse: () => productController.products.first,
                  );
                  Get.to(() => ProductDetailScreen(product: product));
                },
              ),
            );
          },
        );
      }),
    );
  }
}
