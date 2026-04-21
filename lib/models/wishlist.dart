class WishlistItem {
  String id;
  String userId;
  String productId;
  String name;
  double price;
  double? discountPrice;
  String imageUrl;
  String category;
  String addedAt;

  WishlistItem({
    required this.id,
    required this.userId,
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
