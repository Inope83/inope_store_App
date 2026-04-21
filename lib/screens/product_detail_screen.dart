import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../services/notification_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final CartController cartController = Get.find();
  final WishlistController wishlistController = Get.find();
  String selectedSize = 'M';
  String selectedColor = 'Black';
  int quantity = 1;
  bool isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  void _checkWishlistStatus() {
    isInWishlist = wishlistController.isInWishlist(widget.product.id);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Obx(() => Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : Color(0xFF2D2D2D),
                    ),
                    onPressed: () {
                      if (isInWishlist) {
                        wishlistController.removeFromWishlist(product.id);
                        setState(() => isInWishlist = false);
                        NotificationService.showInfo('Hamos husi Wishlist');
                      } else {
                        wishlistController.addToWishlist(product);
                        setState(() => isInWishlist = true);
                        NotificationService.showSuccess('Tau iha Wishlist');
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined,
                        color: Color(0xFF2D2D2D)),
                    onPressed: () => Get.toNamed('/cart'),
                  ),
                ],
              )),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              color: const Color(0xFFF5F5F5),
              child: Center(
                child: Text(product.imageUrl,
                    style: const TextStyle(fontSize: 120)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(product.name,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D2D))),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (product.hasDiscount)
                            Text('\$${product.price}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                    color: Color(0xFF888888))),
                          const SizedBox(height: 4),
                          Text('\$${product.finalPrice}',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < product.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text('(${product.rating})',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF888888))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  const Text('Deskrisaun',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D))),
                  const SizedBox(height: 8),
                  Text(product.description,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF666666))),
                  const SizedBox(height: 16),
                  // Size Selection
                  const Text('Tamanho',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D))),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: product.sizes.length,
                      itemBuilder: (context, index) {
                        final size = product.sizes[index];
                        final isSelected = selectedSize == size;
                        return GestureDetector(
                          onTap: () => setState(() => selectedSize = size),
                          child: Container(
                            width: 50,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2D2D2D)
                                  : Colors.white,
                              border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF2D2D2D)
                                      : const Color(0xFFE0E0E0)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(size,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF2D2D2D),
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Color Selection
                  const Text('Kor',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D))),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: product.colors.length,
                      itemBuilder: (context, index) {
                        final color = product.colors[index];
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = color),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2D2D2D)
                                  : Colors.white,
                              border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF2D2D2D)
                                      : const Color(0xFFE0E0E0)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(color,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF2D2D2D))),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quantity
                  const Text('Quantidade',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (quantity > 1) setState(() => quantity--);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(child: Text('-',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('$quantity',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => setState(() => quantity++),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(child: Text('+',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        cartController.addToCart(
                          productId: product.id,
                          name: product.name,
                          price: product.finalPrice,
                          size: selectedSize,
                          color: selectedColor,
                          imageUrl: product.imageUrl,
                          quantity: quantity,
                        );
                        NotificationService.showSuccess(
                            'Tau iha Karréta ho suksesu');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D2D2D),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Tau iha Karréta',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
