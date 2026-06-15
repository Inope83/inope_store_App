class WishlistItem {
  final int id;
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

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      productId: (json['product_id'] ?? '').toString(),
      name: json['name'] ?? '',
      price: _toDouble(json['price']),
      discountPrice: json['discount_price'] != null ? _toDouble(json['discount_price']) : null,
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
      addedAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
