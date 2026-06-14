class ProductModel {
  final int id;
  final String name;
  final String category;
  final int categoryId;
  final double price;
  final double? originalPrice;
  final String description;
  final List<String> imageUrls;
  final int stock;
  final bool isActive;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryId,
    required this.price,
    this.originalPrice,
    required this.description,
    required this.imageUrls,
    required this.stock,
    this.isActive = true,
    required this.createdAt,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  int get discountPercent =>
      hasDiscount ? ((1 - price / originalPrice!) * 100).round() : 0;
  String get firstImage => imageUrls.isNotEmpty ? imageUrls.first : '';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      categoryId: json['category_id'] ?? 0,
      price: _toDouble(json['price']),
      originalPrice: json['original_price'] != null
          ? _toDouble(json['original_price'])
          : null,
      description: json['description'] ?? '',
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      stock: _toInt(json['stock']),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'category_id': categoryId,
    'price': price,
    'original_price': originalPrice,
    'description': description,
    'image_urls': imageUrls,
    'stock': stock,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
  };

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
