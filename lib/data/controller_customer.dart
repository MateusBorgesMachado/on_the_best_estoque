import 'package:on_the_best_estoque/models/customer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ControllerCustomer {
  static const String table = 'customer';
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> insertCustomer(Customer customer) async {
    await _client.from(table).insert(customer.toMap());
  }

  static Future<List<Customer>> getCustomers() async {
    final response = await _client.from(table).select().order('created-at');
    return response.map((item) => Customer.fromMap(item)).toList();
  }

  static Future<Customer> getCustomerById(String id) async {
    final response = await _client.from(table).select().eq('id', id).single();
    return Customer.fromMap(response);
  }

  static Future<void> updateCustomer(Customer customer) async {
    await _client.from(table).update(customer.toMap()).eq('id', customer.id);
  }

  static Future<void> deleteCustomer(String id) async {
    await _client.from(table).delete().eq('id', id);
  }
}
