class UserModel {
  int id;
  String email;
  String name;
  String? phone;
  String role;
  DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.role = 'customer',
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'customer',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
