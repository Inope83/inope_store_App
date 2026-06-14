class CartItemModel {
  final int id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  int quantity;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? 0,
      productId: (json['product_id'] ?? '').toString(),
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      price: _toDouble(json['price']),
      quantity: _toInt(json['quantity'], fallback: 1),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'product_name': productName,
    'product_image': productImage,
    'price': price,
    'quantity': quantity,
  };

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _toInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
