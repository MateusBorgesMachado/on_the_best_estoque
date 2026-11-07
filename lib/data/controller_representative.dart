import 'package:on_the_best_estoque/models/representative.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ControllerRepresentative {
  static const String table = 'representative';
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> insertRepresentative(Representative representative) async {
    await _client.from(table).insert(representative.toMap());
  }

  static Future<List<Representative>> getRepresentatives() async {
    final response = await _client.from(table).select().order('created-at');
    return response.map((item) => Representative.fromMap(item)).toList();
  }

  static Future<Representative> getRepresentativeById(String id) async {
    final response = await _client.from(table).select().eq('id', id).single();
    return Representative.fromMap(response);
  }

  static Future<void> updateRepresentative(Representative representative) async {
    await _client
        .from(table)
        .update(representative.toMap())
        .eq('id', representative.id);
  }

  static Future<void> deleteRepresentative(String id) async {
    await _client.from(table).delete().eq('id', id);
  }
}
