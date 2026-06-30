import 'dart:convert';
import 'package:get/get.dart';
import '../models/wishlist_item.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class WishlistController extends GetxController {
  final ApiService _api = ApiService();
  final AuthController _auth = Get.find();
  final RxList<WishlistItem> wishlist = <WishlistItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_auth.currentUser, (user) {
      if (user != null) {
        fetchWishlist();
      } else {
        wishlist.clear();
      }
    });
  }

  bool isInWishlist(String productId) =>
      wishlist.any((item) => item.productId == productId);

  Future<void> fetchWishlist() async {
    isLoading.value = true;
    try {
      final res = await _api.get('/wishlist/');
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        wishlist.value = data.map((e) => WishlistItem.fromJson(e)).toList();
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<bool> addToWishlist({
    required String productId,
    required String name,
    required double price,
    required String imageUrl,
  }) async {
    try {
      final res = await _api.post('/wishlist/', body: {
        'product_id': productId,
        'name': name,
        'price': price,
        'image_url': imageUrl,
      });
      if (res.statusCode == 201) {
        await fetchWishlist();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> removeFromWishlist(int itemId) async {
    try {
      final res = await _api.delete('/wishlist/$itemId/');
      if (res.statusCode == 204) {
        wishlist.removeWhere((item) => item.id == itemId);
      }
    } catch (_) {}
  }
}
