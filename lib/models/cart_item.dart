class CartItemModel {
  String id;
  String productId;
  String userId;
  String name;
  double price;
  int quantity;
  String size;
  String color;
  String imageUrl;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.size,
    required this.color,
    required this.imageUrl,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'size': size,
      'color': color,
      'image_url': imageUrl,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}
