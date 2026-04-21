import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../models/wishlist_item.dart';
import '../database/database_helper.dart';
import 'auth_controller.dart';

class WishlistController extends GetxController {
  final AuthController _authController = Get.find();
  final RxList<WishlistItem> wishlistItems = <WishlistItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    ever(_authController.currentUser, (user) {
      if (user != null) loadWishlist();
    });
  }

  Future<void> loadWishlist() async {
    if (_authController.userId.isEmpty) return;
    
    final db = await DatabaseHelper().database;
    final result = await db.query('wishlist',
        where: 'user_id = ?', whereArgs: [_authController.userId]);
    
    wishlistItems.value = result.map((item) {
      return WishlistItem(
        id: item['id'],
        productId: item['product_id'],
        name: item['name'],
        price: item['price'].toDouble(),
        discountPrice: item['discount_price']?.toDouble(),
        imageUrl: item['image_url'],
        category: item['category'],
        addedAt: DateTime.parse(item['added_at']),
      );
    }).toList();
  }

  Future<void> addToWishlist(Product product) async {
    if (_authController.userId.isEmpty) {
      Get.toNamed('/login');
      return;
    }

    final db = await DatabaseHelper().database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    await db.insert('wishlist', {
      'id': id,
      'user_id': _authController.userId,
      'product_id': product.id,
      'name': product.name,
      'price': product.price,
      'discount_price': product.discountPrice,
      'image_url': product.imageUrl,
      'category': product.category,
      'added_at': DateTime.now().toIso8601String(),
    });
    
    await loadWishlist();
  }

  Future<void> removeFromWishlist(String productId) async {
    final db = await DatabaseHelper().database;
    await db.delete('wishlist',
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [_authController.userId, productId]);
    
    await loadWishlist();
  }

  bool isInWishlist(String productId) {
    return wishlistItems.any((item) => item.productId == productId);
  }

  int get wishlistCount => wishlistItems.length;
}
import '../models/product.dart';
