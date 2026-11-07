import 'package:on_the_best_estoque/data/map_utils.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final double costPrice;
  final double finalPrice;
  final String lastPurchaseDate;
  final int stockQuantity;

  Product({
    this.id = '',
    required this.name,
    required this.category,
    required this.subcategory,
    required this.costPrice,
    required this.finalPrice,
    required this.lastPurchaseDate,
    required this.stockQuantity,
  });

  factory Product.fromMap(Map<String, dynamic> item) {
    return Product(
      id: toText(item['id']),
      name: toText(item['name']),
      category: toText(item['category']),
      subcategory: toText(item['sub-category']),
      costPrice: toDouble(item['cost-price']),
      finalPrice: toDouble(item['final-price']),
      lastPurchaseDate: toText(item['last-purchase-date']),
      stockQuantity: toInt(item['stock-quantity']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'sub-category': subcategory,
      'cost-price': costPrice,
      'final-price': finalPrice,
      'last-purchase-date': lastPurchaseDate,
      'stock-quantity': stockQuantity,
    };
  }
}
