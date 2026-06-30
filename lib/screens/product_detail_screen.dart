import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../models/product_model.dart';
import '../utils/format_utils.dart';
import '../utils/app_colors.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final WishlistController _wishlistCtrl = Get.find();
  ProductModel? product;
  int _currentImage = 0;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;
  bool _isAdding = false;
  bool _showFullDescription = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productId = Get.parameters['id'];
    if (productId != null && product == null) {
      product = Get.find<ProductController>().getProductById(productId);
      if (product == null) {
        Get.snackbar('Sala', 'Produtu la hetan',
            snackPosition: SnackPosition.BOTTOM);
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) return const SizedBox.shrink();
    final p = product!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  const Spacer(),
                  Obx(() {
                    final isFav = _wishlistCtrl.isInWishlist('${product!.id}');
                    return IconButton(
                      onPressed: () async {
                        if (isFav) {
                          final item = _wishlistCtrl.wishlist.firstWhereOrNull(
                              (i) => i.productId == '${product!.id}');
                          if (item != null) {
                            await _wishlistCtrl.removeFromWishlist(item.id);
                          }
                        } else {
                          await _wishlistCtrl.addToWishlist(
                            productId: '${product!.id}',
                            name: product!.name,
                            price: product!.price,
                            imageUrl: product!.firstImage,
                          );
                        }
                      },
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_outline,
                        size: 20,
                        color: isFav ? AppColors.red : null,
                      ),
                    );
                  }),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageGallery(p),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(p),
                          const SizedBox(height: 16),
                          _buildSizeSelector(p),
                          const SizedBox(height: 16),
                          _buildColorSelector(p),
                          const SizedBox(height: 16),
                          _buildQuantitySelector(p),
                          const SizedBox(height: 16),
                          _buildDescription(p),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(p),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(ProductModel p) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: PageView.builder(
            onPageChanged: (i) => setState(() => _currentImage = i),
            itemCount: p.imageUrls.isNotEmpty ? p.imageUrls.length : 1,
            itemBuilder: (_, i) {
              final imgUrl = p.imageUrls.isNotEmpty
                  ? p.imageUrls[i]
                  : '';
              return Container(
                color: AppColors.imageBg,
                child: imgUrl.isNotEmpty
                    ? Image.network(imgUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 60))
                    : const Icon(Icons.shopping_bag, size: 60, color: AppColors.placeholder),
              );
            },
          ),
        ),
        if (p.imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(p.imageUrls.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentImage == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentImage == i ? AppColors.dark : AppColors.placeholder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(ProductModel p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(p.category, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(FormatUtils.formatPrice(p.price),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            if (p.hasDiscount) ...[
              const SizedBox(width: 8),
              Text(FormatUtils.formatPrice(p.originalPrice!),
                  style: const TextStyle(fontSize: 14, color: AppColors.textMuted, decoration: TextDecoration.lineThrough)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(4)),
                child: Text('-${p.discountPercent}%',
                    style: const TextStyle(fontSize: 10, color: AppColors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            ...List.generate(5, (i) => Icon(
              i < p.rating.round() ? Icons.star : Icons.star_border,
              size: 16, color: AppColors.star,
            )),
            const SizedBox(width: 6),
            Text('(${p.rating.toStringAsFixed(1)})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const Spacer(),
            Text('Stok: ${p.stock}', style: TextStyle(fontSize: 12, color: p.stock <= 5 ? AppColors.red : AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeSelector(ProductModel p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tamanhu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: p.sizes.map((size) {
            final selected = _selectedSize == size;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.dark : AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected ? AppColors.dark : AppColors.border),
                ),
                child: Text(size,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                        color: selected ? AppColors.white : AppColors.textLight)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector(ProductModel p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kór', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: p.colors.map((color) {
            final selected = _selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.dark : AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected ? AppColors.dark : AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color == 'White' ? AppColors.placeholder : Colors.transparent),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(color,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                            color: selected ? AppColors.white : AppColors.textLight)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(ProductModel p) {
    return Row(
      children: [
        const Text('Kuantidade', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const Spacer(),
        GestureDetector(
          onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: _quantity > 1 ? AppColors.dark : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.remove, size: 16,
                color: _quantity > 1 ? AppColors.white : Colors.grey.shade400),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('$_quantity',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        GestureDetector(
          onTap: _quantity < p.stock ? () => setState(() => _quantity++) : null,
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: _quantity < p.stock ? AppColors.dark : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add, size: 16,
                color: _quantity < p.stock ? AppColors.white : Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ProductModel p) {
    final desc = p.description;
    final isLong = desc.length > 150;
    final displayText = isLong && !_showFullDescription
        ? '${desc.substring(0, 150)}... '
        : '$desc ';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Deskrisaun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: displayText,
                style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.5),
              ),
              if (isLong)
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => setState(() => _showFullDescription = !_showFullDescription),
                    child: Text(
                      _showFullDescription ? 'Show Less' : 'Show More',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ProductModel p) {
    final total = p.price * _quantity;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(FormatUtils.formatPrice(total),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: p.stock > 0 ? _addToCart : null,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: p.stock > 0 ? AppColors.dark : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _isAdding
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                        : const Text('+ Karréta', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart() async {
    if (product == null) return;
    final p = product!;
    setState(() => _isAdding = true);
    await Get.find<CartController>().addToCart(
      productId: p.id.toString(),
      name: p.name,
      price: p.price,
      imageUrl: p.firstImage,
      quantity: _quantity,
    );
    setState(() => _isAdding = false);
  }

  Color _parseColor(String name) {
    switch (name.toLowerCase()) {
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      case 'blue': return Colors.blue;
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'pink': return Colors.pink;
      case 'grey': case 'gray': return Colors.grey;
      case 'brown': return Colors.brown;
      default: return AppColors.textSecondary;
    }
  }

}
