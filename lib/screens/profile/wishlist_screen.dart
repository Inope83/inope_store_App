import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wishlist_controller.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WishlistController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.items.isEmpty) {
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
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
              ),
              elevation: 0,
              borderOnForeground: true,
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item['image_url'] != null && (item['image_url'] as String).isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item['image_url'], fit: BoxFit.cover),
                        )
                      : const Icon(Icons.image, color: Colors.grey),
                ),
                title: Text(item['name'] ?? '',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text('Rp ${(item['price'] as num?)?.toDouble().toStringAsFixed(0) ?? 0}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFFE53935), fontWeight: FontWeight.w600)),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => controller.removeFromWishlist(item['id']),
                ),
                onTap: () {
                  // Navigate to detail if we have product data? 
                  // For now just keep as is
                },
              ),
            );
          },
        );
      }),
    );
  }
}
