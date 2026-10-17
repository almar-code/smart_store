class UserAddressModel {
  final int addressId;
  final int customerId;
  final String title;
  final String country;
  final String city;
  final String street;
  final String? building;
  final String? postalCode;
  final bool isDefault;

  UserAddressModel({
    required this.addressId,
    required this.customerId,
    required this.title,
    required this.country,
    required this.city,
    required this.street,
    this.building,
    this.postalCode,
    required this.isDefault,
  });

  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    return UserAddressModel(
      addressId: json['address_id'],
      customerId: json['customer_id'],
      title: json['title'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      street: json['street'] ?? '',
      building: json['building'],
      postalCode: json['postal_code'],
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'country': country,
      'city': city,
      'street': street,
      'building': building,
      'postal_code': postalCode,
      'is_default': isDefault,
    };
  }
}