import 'package:on_the_best_estoque/models/product_group.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ControllerProductGroup {
  static const String table = 'product-group';
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> insertGroup(ProductGroup group) async {
    await _client.from(table).insert(group.toMap());
  }

  static Future<List<ProductGroup>> getGroups() async {
    final response = await _client.from(table).select().order('name');
    return response.map((item) => ProductGroup.fromMap(item)).toList();
  }

  static Future<void> deleteGroup(String id) async {
    await _client.from(table).delete().eq('id', id);
  }
}

class ControllerProductSubgroup {
  static const String table = 'product-subgroup';
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> insertSubgroup(ProductSubgroup subgroup) async {
    await _client.from(table).insert(subgroup.toMap());
  }

  static Future<List<ProductSubgroup>> getSubgroups() async {
    final response = await _client.from(table).select().order('name');
    return response.map((item) => ProductSubgroup.fromMap(item)).toList();
  }

  static Future<List<ProductSubgroup>> getSubgroupsByGroup(String groupId) async {
    final response = await _client
        .from(table)
        .select()
        .eq('group-id', groupId)
        .order('name');
    return response.map((item) => ProductSubgroup.fromMap(item)).toList();
  }

  static Future<void> deleteSubgroup(String id) async {
    await _client.from(table).delete().eq('id', id);
  }
}
