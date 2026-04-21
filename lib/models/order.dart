class OrderModel {
  String id;
  String userId;
  double totalAmount;
  String status;
  String paymentMethod;
  String address;
  DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.address,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_amount': totalAmount,
      'status': status,
      'payment_method': paymentMethod,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? '',
      address: json['address'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
