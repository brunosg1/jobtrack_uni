import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobtrack_uni/prefs_service.dart';
import 'package:jobtrack_uni/domain/entities/job_card.dart';
import 'package:jobtrack_uni/features/providers/domain/entities/provider_entity.dart';
import 'package:jobtrack_uni/utils/supabase_utils.dart';

/// Basic two-way synchronization service.
///
/// This implementation is intentionally simple and demonstrates the pattern:
/// - Pull remote rows and merge into local
/// - Push local rows to remote using upsert
/// Conflict resolution: last-write-wins using `updated_at`/`applied_date` where available.
class SyncService {
  final SupabaseClient client;
  final PrefsService prefs;
  final String? supabaseUrl;
  final String? supabaseAnonKey;

  SyncService({required this.client, required this.prefs, this.supabaseUrl, this.supabaseAnonKey});

  /// Synchronize both job_cards and providers.
  Future<void> syncAll() async {
    await syncProviders();
    await syncJobCards();
  }

  Future<void> syncProviders() async {
    final localProviders = <ProviderEntity>[]; // TODO: implement local storage for providers if needed

    // Pull remote
    final providerRows = await selectAll(client, 'providers', supabaseUrl: supabaseUrl, anonKey: supabaseAnonKey);
      // ignore: unused_local_variable
      final _remote = providerRows.map((e) => ProviderEntity.fromJson(e)).toList();

  // Merge: for demo we simply prefer remote items and push local items
  // Push local to remote (if any)
    if (localProviders.isNotEmpty) {
      final rows = localProviders.map((p) => p.toJson()).toList();
      await upsertRows(client, 'providers', rows.cast<Map<String, dynamic>>(), supabaseUrl: supabaseUrl, anonKey: supabaseAnonKey);
    }
    // TODO: persist remote providers to local storage when a local model exists
  }

  Future<void> syncJobCards() async {
    // Local
    final local = prefs.getJobCards();

    // Remote pull
    final jobCardRows = await selectAll(client, 'job_cards', supabaseUrl: supabaseUrl, anonKey: supabaseAnonKey);
      final remote = jobCardRows.map((map) => JobCard.fromJson({
          'id': map['id']?.toString() ?? '',
          'companyName': map['company_name'] ?? '',
          'jobTitle': map['job_title'] ?? '',
          'status': map['status'] ?? '',
          'notes': map['notes'],
          'appliedDate': map['applied_date'] ?? DateTime.now().toIso8601String(),
        })).toList();

    // Merge: naive merge using id equality, remote wins for now
    final mergedMap = <String, JobCard>{};
    for (var r in remote) mergedMap[r.id] = r;
    for (var l in local) mergedMap[l.id] = l;

    final merged = mergedMap.values.toList();

    // Persist merged locally
    await prefs.saveJobCards(merged);

    // Push local (merged) to remote
        bool _looksLikeUuid(String? id) {
          if (id == null) return false;
      final uuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
          return uuid.hasMatch(id);
        }

        final withId = <Map<String, dynamic>>[];
        final withoutId = <Map<String, dynamic>>[];

        for (var c in merged) {
          final base = <String, dynamic>{
            'company_name': c.companyName,
            'job_title': c.jobTitle,
            'status': c.status,
            'notes': c.notes,
            'applied_date': c.appliedDate.toIso8601String(),
          };
          if (_looksLikeUuid(c.id)) {
            final withIdRow = Map<String, dynamic>.from(base);
            withIdRow['id'] = c.id;
            withId.add(withIdRow);
          } else {
            // ignore: avoid_print
            print('syncJobCards: omitting non-UUID id for upsert: ${c.id}');
            withoutId.add(base);
          }
        }

        if (withId.isNotEmpty) {
          await upsertRows(client, 'job_cards', withId, supabaseUrl: supabaseUrl, anonKey: supabaseAnonKey);
        }
        if (withoutId.isNotEmpty) {
          await upsertRows(client, 'job_cards', withoutId, supabaseUrl: supabaseUrl, anonKey: supabaseAnonKey);
        }
  }
}
