import 'package:on_the_best_estoque/data/map_utils.dart';

class ProductGroup {
  final String id;
  final String name;

  ProductGroup({
    this.id = '',
    required this.name,
  });

  factory ProductGroup.fromMap(Map<String, dynamic> item) {
    return ProductGroup(
      id: toText(item['id']),
      name: toText(item['name']),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}

class ProductSubgroup {
  final String id;
  final String name;
  final String groupId;

  ProductSubgroup({
    this.id = '',
    required this.name,
    required this.groupId,
  });

  factory ProductSubgroup.fromMap(Map<String, dynamic> item) {
    return ProductSubgroup(
      id: toText(item['id']),
      name: toText(item['name']),
      groupId: toText(item['group-id']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'group-id': groupId,
    };
  }
}
