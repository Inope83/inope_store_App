class CartItemModel {
  final int id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  int quantity;
  final double subtotal;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.subtotal = 0,
  });

  double get totalPrice => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final price = _toDouble(json['price']);
    final quantity = _toInt(json['quantity'], fallback: 1);
    return CartItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      productId: (json['product_id'] ?? '').toString(),
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      price: price,
      quantity: quantity,
      subtotal: json['subtotal'] != null ? _toDouble(json['subtotal']) : price * quantity,
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
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _toInt(dynamic value, {required int fallback}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
