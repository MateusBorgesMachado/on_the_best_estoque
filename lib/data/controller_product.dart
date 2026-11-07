import 'package:on_the_best_estoque/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ControllerProduct {
  static const String table = 'product';
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> insertProduct(Product product) async {
    await _client.from(table).insert(product.toMap());
  }

  static Future<List<Product>> getProducts() async {
    final response = await _client.from(table).select().order('created-at');
    return response.map((item) => Product.fromMap(item)).toList();
  }

  static Future<Product> getProductById(String id) async {
    final response = await _client.from(table).select().eq('id', id).single();
    return Product.fromMap(response);
  }

  static Future<void> updateProduct(Product product) async {
    await _client.from(table).update(product.toMap()).eq('id', product.id);
  }

  static Future<void> deleteProduct(String id) async {
    await _client.from(table).delete().eq('id', id);
  }
}
