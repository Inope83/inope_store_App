class OrderModel {
  int id;
  int userId;
  String userName;
  String userEmail;
  double total;
  String status;
  String paymentMethod;
  String address;
  List<dynamic> items;
  DateTime createdAt;
  DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    this.userName = '',
    this.userEmail = '',
    required this.total,
    this.status = 'pending',
    this.paymentMethod = '',
    this.address = '',
    this.items = const [],
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'user_name': userName,
      'user_email': userEmail,
      'total': total,
      'status': status,
      'payment_method': paymentMethod,
      'address': address,
      'items': items,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user'] is int ? json['user'] : int.tryParse(json['user'].toString()) ?? 0,
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      total: _toDouble(json['total']),
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? '',
      address: json['address'] ?? '',
      items: json['items'] is List ? json['items'] : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
