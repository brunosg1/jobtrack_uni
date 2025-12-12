import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobtrack_uni/features/providers/domain/repositories/providers_repository.dart';
import 'package:jobtrack_uni/features/providers/domain/entities/provider_entity.dart';
import 'package:jobtrack_uni/utils/supabase_utils.dart';

/// Supabase implementation of [ProvidersRepository].
class SupabaseProvidersRepository implements ProvidersRepository {
  final SupabaseClient client;
  final String table;
  final String? supabaseUrl;
  final String? supabaseAnonKey;

  SupabaseProvidersRepository(this.client, {this.table = 'providers', this.supabaseUrl, this.supabaseAnonKey});

  @override
  Future<List<ProviderEntity>> getProviders() async {
    final rows = await selectAll(client, table, supabaseUrl: supabaseUrl, anonKey: supabaseAnonKey);
    return rows.map((map) => ProviderEntity.fromJson(map)).toList();
  }

  @override
  Future<bool> saveProviders(List<ProviderEntity> providers) async {
    try {
      final rows = providers.map((p) => p.toJson()).toList();
      // upsert rows with helper (may fallback to HTTP)
      await upsertRows(client, table, rows, supabaseUrl: supabaseUrl, anonKey: supabaseAnonKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> upsertProvider(ProviderEntity provider) async {
    try {
      await upsertRows(client, table, [provider.toJson()], supabaseUrl: supabaseUrl, anonKey: supabaseAnonKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> removeProvider(String id) async {
    try {
      await deleteById(client, table, id, supabaseUrl: supabaseUrl, anonKey: supabaseAnonKey);
      return true;
    } catch (_) {
      return false;
    }
  }
}
