import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobtrack_uni/features/providers/domain/repositories/providers_repository.dart';
import 'package:jobtrack_uni/features/providers/domain/entities/provider_entity.dart';

/// Supabase implementation of [ProvidersRepository].
class SupabaseProvidersRepository implements ProvidersRepository {
  final SupabaseClient client;
  final String table;

  SupabaseProvidersRepository(this.client, {this.table = 'providers'});

  @override
  Future<List<ProviderEntity>> getProviders() async {
  final resp = await (client.from(table).select() as dynamic).execute();
  if (resp.error != null) throw resp.error!;
  final data = resp.data as List<dynamic>? ?? <dynamic>[];
    return data.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return ProviderEntity.fromJson(map);
    }).toList();
  }

  @override
  Future<bool> saveProviders(List<ProviderEntity> providers) async {
    try {
      final rows = providers.map((p) => p.toJson()).toList();
  final resp = await (client.from(table).upsert(rows) as dynamic).execute();
  if (resp.error != null) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> upsertProvider(ProviderEntity provider) async {
    try {
  final resp = await (client.from(table).upsert(provider.toJson()) as dynamic).execute();
  if (resp.error != null) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> removeProvider(String id) async {
    try {
  final resp = await (client.from(table).delete().eq('id', id) as dynamic).execute();
  if (resp.error != null) return false;
      return true;
    } catch (_) {
      return false;
    }
  }
}
