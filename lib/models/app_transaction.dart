import 'package:on_the_best_estoque/data/map_utils.dart';

class AppTransaction {
  final String id;
  final String type;
  final String entityName;
  final String date;
  final double totalValue;
  final int itemCount;

  AppTransaction({
    this.id = '',
    required this.type,
    required this.entityName,
    required this.date,
    required this.totalValue,
    required this.itemCount,
  });

  factory AppTransaction.fromMap(Map<String, dynamic> item) {
    return AppTransaction(
      id: toText(item['id']),
      type: toText(item['type']),
      entityName: toText(item['entity-name']),
      date: toText(item['date']),
      totalValue: toDouble(item['total-value']),
      itemCount: toInt(item['item-count']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entity-name': entityName,
      'type': type,
      'item-count': itemCount,
      'total-value': totalValue,
      'date': date,
    };
  }
}
