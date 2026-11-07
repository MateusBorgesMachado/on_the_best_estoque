import 'package:on_the_best_estoque/models/app_transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ControllerTransaction {
  static const String table = 'app-transaction';
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> insertTransaction(AppTransaction transaction) async {
    await _client.from(table).insert(transaction.toMap());
  }

  static Future<List<AppTransaction>> getTransactions() async {
    final response = await _client.from(table).select().order('created-at');
    return response.map((item) => AppTransaction.fromMap(item)).toList();
  }

  static Future<List<AppTransaction>> getTransactionsByEntity(
    String entityName,
  ) async {
    final response = await _client
        .from(table)
        .select()
        .eq('entity-name', entityName)
        .order('created-at');
    return response.map((item) => AppTransaction.fromMap(item)).toList();
  }

  static Future<AppTransaction> getTransactionById(String id) async {
    final response = await _client.from(table).select().eq('id', id).single();
    return AppTransaction.fromMap(response);
  }

  static Future<void> deleteTransaction(String id) async {
    await _client.from(table).delete().eq('id', id);
  }

  static Future<void> updateTransaction(AppTransaction transaction) async {
    await _client
        .from(table)
        .update(transaction.toMap())
        .eq('id', transaction.id);
  }
}
