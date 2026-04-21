class WishlistItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final String category;
  final DateTime addedAt;

  WishlistItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    required this.category,
    required this.addedAt,
  });

  double get finalPrice => discountPrice ?? price;
}
