class AddressModel {
  String id;
  String userId;
  String label;
  String fullName;
  String phone;
  String address;
  String city;
  String district;
  String postalCode;
  int isDefault;

  AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.district,
    required this.postalCode,
    this.isDefault = 0,
  });
}
