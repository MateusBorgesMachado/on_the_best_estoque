import 'package:on_the_best_estoque/data/map_utils.dart';

class Customer {
  final String id;
  final String name;
  final String status;
  final String contactNumber;
  final String lastPurchaseDate;
  final double totalSpent;

  Customer({
    this.id = '',
    required this.name,
    required this.status,
    required this.contactNumber,
    required this.lastPurchaseDate,
    required this.totalSpent,
  });

  factory Customer.fromMap(Map<String, dynamic> item) {
    return Customer(
      id: toText(item['id']),
      name: toText(item['name']),
      status: toText(item['status']),
      contactNumber: toText(item['contact-number']),
      lastPurchaseDate: toText(item['last-purchase-date']),
      totalSpent: toDouble(item['total-spent']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
      'contact-number': contactNumber,
      'last-purchase-date': lastPurchaseDate,
      'total-spent': totalSpent,
    };
  }
}
