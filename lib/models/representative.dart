import 'package:on_the_best_estoque/data/map_utils.dart';

class Representative {
  final String id;
  final String storeName;
  final String repName;
  final String address;
  final String contactNumber;
  final String email;

  Representative({
    this.id = '',
    required this.storeName,
    required this.repName,
    required this.address,
    required this.contactNumber,
    required this.email,
  });

  factory Representative.fromMap(Map<String, dynamic> item) {
    return Representative(
      id: toText(item['id']),
      storeName: toText(item['store-name']),
      repName: toText(item['rep-name']),
      address: toText(item['address']),
      contactNumber: toText(item['contact-number']),
      email: toText(item['email']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'store-name': storeName,
      'rep-name': repName,
      'address': address,
      'contact-number': contactNumber,
      'email': email,
    };
  }
}
