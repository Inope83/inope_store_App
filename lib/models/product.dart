class Product {
  String id;
  String name;
  String description;
  double price;
  double? discountPrice;
  String category;
  String imageUrl;
  double rating;
  bool isNew;
  bool isFeatured;
  List<String> sizes;
  List<String> colors;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.category,
    required this.imageUrl,
    this.rating = 0,
    this.isNew = false,
    this.isFeatured = false,
    this.sizes = const ['S', 'M', 'L', 'XL'],
    this.colors = const ['Black', 'White', 'Blue'],
  });

  double get finalPrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'category': category,
      'image_url': imageUrl,
      'rating': rating,
      'is_new': isNew ? 1 : 0,
      'is_featured': isFeatured ? 1 : 0,
      'sizes': sizes.join(','),
      'colors': colors.join(','),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discount_price']?.toDouble(),
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      isNew: (json['is_new'] ?? 0) == 1,
      isFeatured: (json['is_featured'] ?? 0) == 1,
      sizes: (json['sizes'] as String?)?.split(',') ?? ['S', 'M', 'L', 'XL'],
      colors: (json['colors'] as String?)?.split(',') ?? ['Black', 'White', 'Blue'],
    );
  }
}
