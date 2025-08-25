import 'dto/language_content.dart';

class Merchant {
  final String id;
  final LanguageContent name;
  final LanguageContent address;
  final String category_code;

  Merchant({
    required this.id,
    required this.name,
    required this.address,
    required this.category_code,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] as String,
      name: LanguageContent.fromJson(json['name'] as Map<String, dynamic>),
      address: LanguageContent.fromJson(json['address'] as Map<String, dynamic>),
      category_code: json['category_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.toJson(),
      'address': address.toJson(),
      'category_code': category_code,
    };
  }
}
