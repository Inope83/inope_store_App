import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductModel product;
  int _currentImage = 0;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;
  bool _isAdding = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productId = Get.parameters['id'];
    if (productId != null) {
      final found = Get.find<ProductController>().getProductById(productId);
      if (found != null) {
        product = found;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_outline, size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Images ────────────────────────
                    _buildImageGallery(),
                    // ── Info ──────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 16),
                          // ── Size ───────────────────────
                          _buildSizeSelector(),
                          const SizedBox(height: 16),
                          // ── Color ──────────────────────
                          _buildColorSelector(),
                          const SizedBox(height: 16),
                          // ── Quantity ───────────────────
                          _buildQuantitySelector(),
                          const SizedBox(height: 16),
                          // ── Description ────────────────
                          _buildDescription(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Bottom Bar ───────────────────────────
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Column(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: PageView.builder(
            onPageChanged: (i) => setState(() => _currentImage = i),
            itemCount: product.imageUrls.isNotEmpty ? product.imageUrls.length : 1,
            itemBuilder: (_, i) {
              final imgUrl = product.imageUrls.isNotEmpty
                  ? product.imageUrls[i]
                  : '';
              return Container(
                color: const Color(0xFFF0F0F0),
                child: imgUrl.isNotEmpty
                    ? Image.network(imgUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 60))
                    : const Icon(Icons.shopping_bag, size: 60, color: Color(0xFFCCCCCC)),
              );
            },
          ),
        ),
        if (product.imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(product.imageUrls.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentImage == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentImage == i ? const Color(0xFF1A1A1A) : const Color(0xFFCCCCCC),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.category, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
        const SizedBox(height: 4),
        Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('\$${_fmt(product.price)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
            if (product.hasDiscount) ...[
              const SizedBox(width: 8),
              Text('\$${_fmt(product.originalPrice!)}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFFAAAAAA), decoration: TextDecoration.lineThrough)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(4)),
                child: Text('-${product.discountPercent}%',
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            ...List.generate(5, (i) => Icon(
              i < product.rating.round() ? Icons.star : Icons.star_border,
              size: 16, color: const Color(0xFFF59E0B),
            )),
            const SizedBox(width: 6),
            Text('(${product.rating.toStringAsFixed(1)})', style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
            const Spacer(),
            Text('Stok: ${product.stock}', style: TextStyle(fontSize: 12, color: product.stock <= 5 ? const Color(0xFFE53935) : const Color(0xFF888888))),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tamanhu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: product.sizes.map((size) {
            final selected = _selectedSize == size;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected ? const Color(0xFF1A1A1A) : const Color(0xFFE0E0E0)),
                ),
                child: Text(size,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : const Color(0xFF555555))),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kór', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: product.colors.map((color) {
            final selected = _selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected ? const Color(0xFF1A1A1A) : const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color == 'White' ? const Color(0xFFCCCCCC) : Colors.transparent),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(color,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                            color: selected ? Colors.white : const Color(0xFF555555))),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text('Kuantidade', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const Spacer(),
        GestureDetector(
          onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: _quantity > 1 ? const Color(0xFF1A1A1A) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.remove, size: 16,
                color: _quantity > 1 ? Colors.white : Colors.grey.shade400),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('$_quantity',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        GestureDetector(
          onTap: _quantity < product.stock ? () => setState(() => _quantity++) : null,
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: _quantity < product.stock ? const Color(0xFF1A1A1A) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add, size: 16,
                color: _quantity < product.stock ? Colors.white : Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Deskrisaun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        Text(product.description.isNotEmpty ? product.description : 'Seidauk iha deskrisaun.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.5)),
      ],
    );
  }

  Widget _buildBottomBar() {
    final total = product.price * _quantity;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  const Text('Total', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
                  Text('\$${_fmt(total)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: product.stock > 0 ? _addToCart : null,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: product.stock > 0 ? const Color(0xFF1A1A1A) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _isAdding
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('+ Karréta', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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
    setState(() => _isAdding = true);
    await Get.find<CartController>().addToCart(
      productId: product.id.toString(),
      name: product.name,
      price: product.price,
      imageUrl: product.firstImage,
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
      default: return const Color(0xFF888888);
    }
  }

  String _fmt(double price) {
    final intPart = price.toInt();
    final formatted = intPart.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return formatted;
  }
}
