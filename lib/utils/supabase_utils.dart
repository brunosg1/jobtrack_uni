import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Try to execute a Postgrest/PostgrestFilter builder using multiple
/// method names to remain compatible with different supabase_flutter versions.
Future<dynamic> executeBuilder(dynamic builder, {bool expectSingle = false}) async {
  // Try a few method names used across different PostgREST client versions.
  final attempts = <String>['execute', 'get'];
  Exception? lastError;
  for (final method in attempts) {
    try {
      // Attempt to call the method by name using `Function.apply` isn't available
      // for arbitrary method names on dynamic. Instead we try the common method
      // names directly.
  switch (method) {
        case 'execute':
          // ignore: avoid_dynamic_calls
          final r = await (builder as dynamic).execute();
          // ignore: avoid_print
          print('executeBuilder: succeeded using execute()');
          return r;
        case 'get':
          // ignore: avoid_dynamic_calls
          final r = await (builder as dynamic).get();
          // ignore: avoid_print
          print('executeBuilder: succeeded using get()');
          return r;
        case 'maybeSingle':
          // ignore: avoid_dynamic_calls
          final r = await (builder as dynamic).maybeSingle();
          // ignore: avoid_print
          print('executeBuilder: succeeded using maybeSingle()');
          return r;
        case 'single':
          // ignore: avoid_dynamic_calls
          final r = await (builder as dynamic).single();
          // ignore: avoid_print
          print('executeBuilder: succeeded using single()');
          return r;
      }
    } catch (e) {
      lastError = Exception('Attempt $method failed: $e');
      // ignore: avoid_print
      print('executeBuilder: attempt $method failed: $e');
    }
  }

  throw Exception('Could not execute builder; unsupported PostgREST API surface. Last error: $lastError');
}

// exported for tests
String normalizeSupabaseUrl(String url) {
  var u = url.trim();
  if (u.startsWith('hhttps')) {
    u = u.replaceFirst('hhttps', 'https');
  }
  if (!u.startsWith('http://') && !u.startsWith('https://')) {
    u = 'https://$u';
  }
  return u;
}

// Detect whether given supabase URL/anonKey look like the example placeholders
// included in the repo. When placeholders are present we should avoid
// attempting real HTTP requests which will always fail and be noisy.
// exported for tests
bool looksLikePlaceholder(String? url, String? key) {
  if (url == null || key == null) return false;
  final lowerUrl = url.toLowerCase();
  final lowerKey = key.toLowerCase();
  return lowerUrl.contains('replace_with') || lowerUrl.contains('your_project') || lowerKey.contains('replace_with');
}

/// Generic retry wrapper with exponential backoff.
Future<T> _withRetries<T>(
  Future<T> Function() fn, {
  int attempts = 3,
  Duration initialDelay = const Duration(milliseconds: 500),
}) async {
  var delay = initialDelay;
  for (var i = 0; i < attempts; i++) {
    try {
      return await fn();
    } catch (e, st) {
      developer.log('Attempt ${i + 1} failed: $e', name: 'supabase_utils', error: e, stackTrace: st);
      if (i == attempts - 1) rethrow;
      await Future.delayed(delay);
      delay *= 2;
    }
  }
  // should never reach here
  throw Exception('Retries exhausted');
}

Future<List<Map<String, dynamic>>> _httpSelectAll(String supabaseUrl, String anonKey, String table) async {
  return _withRetries(() async {
    final normalized = normalizeSupabaseUrl(supabaseUrl).replaceAll(RegExp(r'/?$'), '');
    developer.log('HTTP select fallback: using URL $normalized for table $table', name: 'supabase_utils');
    final uri = Uri.parse('$normalized/rest/v1/$table?select=*');
    final client = HttpClient();
    try {
      final req = await client.getUrl(uri);
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      req.headers.set('apikey', anonKey);
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $anonKey');
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = json.decode(body) as List<dynamic>;
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      throw Exception('HTTP select failed: ${res.statusCode} ${res.reasonPhrase} - $body');
    } finally {
      client.close(force: true);
    }
  });
}

Future<void> _httpUpsert(String supabaseUrl, String anonKey, String table, List<Map<String, dynamic>> rows) async {
  return _withRetries(() async {
    final normalized = normalizeSupabaseUrl(supabaseUrl).replaceAll(RegExp(r'/?$'), '');
    developer.log('HTTP upsert fallback: using URL $normalized for table $table', name: 'supabase_utils');
    final uri = Uri.parse('$normalized/rest/v1/$table');
    final client = HttpClient();
    try {
      final req = await client.postUrl(uri);
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.headers.set('apikey', anonKey);
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $anonKey');
      req.headers.set('Prefer', 'resolution=merge-duplicates');
      req.add(utf8.encode(json.encode(rows)));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode >= 200 && res.statusCode < 300) return;
      throw Exception('HTTP upsert failed: ${res.statusCode} ${res.reasonPhrase} - $body');
    } finally {
      client.close(force: true);
    }
  });
}

Future<void> _httpDeleteById(String supabaseUrl, String anonKey, String table, String id) async {
  return _withRetries(() async {
    final normalized = normalizeSupabaseUrl(supabaseUrl).replaceAll(RegExp(r'/?$'), '');
    developer.log('HTTP delete fallback: using URL $normalized for table $table id $id', name: 'supabase_utils');
    final uri = Uri.parse('$normalized/rest/v1/$table?id=eq.$id');
    final client = HttpClient();
    try {
      final req = await client.deleteUrl(uri);
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      req.headers.set('apikey', anonKey);
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $anonKey');
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode >= 200 && res.statusCode < 300) return;
      throw Exception('HTTP delete failed: ${res.statusCode} ${res.reasonPhrase} - $body');
    } finally {
      client.close(force: true);
    }
  });
}

Future<List<Map<String, dynamic>>> selectAll(SupabaseClient client, String table, {String? supabaseUrl, String? anonKey}) async {
  // If caller provided the example placeholder values, avoid attempting
  // network calls — they will always fail and are confusing during local
  // development. Treat placeholders as "no remote configured".
  if (looksLikePlaceholder(supabaseUrl, anonKey)) return [];
  // Prefer HTTP REST for selects when explicit supabaseUrl/anonKey are
  // available. This is more stable across SDK versions and avoids
  // PostgREST builder API mismatches for list queries.
  if (supabaseUrl != null && anonKey != null && supabaseUrl.isNotEmpty && anonKey.isNotEmpty) {
    try {
      return await _httpSelectAll(supabaseUrl, anonKey, table);
    } catch (httpErr) {
      // If HTTP fallback fails, try the client builder as a last resort.
      // ignore: avoid_print
      print('selectAll: HTTP select failed, falling back to SDK builder: $httpErr');
    }
  }

  try {
    final builder = (client.from(table).select()) as dynamic;
    final resp = await executeBuilder(builder, expectSingle: false);
    if (resp == null) return [];
    if (resp is Map && resp.containsKey('data')) {
      final d = resp['data'] as List<dynamic>? ?? [];
      return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (resp is List) return resp.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    if (resp is Map) return [Map<String, dynamic>.from(resp)];
  } catch (e) {
  if (looksLikePlaceholder(supabaseUrl, anonKey)) {
      // If we detected placeholders earlier but still hit this path, avoid
      // attempting HTTP fallback and return an empty list to keep behavior
      // predictable during local development.
      return [];
    }

    if (supabaseUrl != null && anonKey != null && supabaseUrl.isNotEmpty && anonKey.isNotEmpty) {
      try {
        return await _httpSelectAll(supabaseUrl, anonKey, table);
      } catch (httpErr) {
        throw Exception('Could not execute builder for select on $table: $e; HTTP fallback failed: $httpErr');
      }
    }
    throw Exception('Could not execute builder for select on $table: $e');
  }
  throw Exception('Unexpected response shape from select on $table');
}

Future<void> upsertRows(SupabaseClient client, String table, List<Map<String, dynamic>> rows, {String? supabaseUrl, String? anonKey}) async {
  try {
    final builder = (client.from(table).upsert(rows)) as dynamic;
    await executeBuilder(builder);
    // ignore: avoid_print
    print('upsertRows: SDK builder succeeded for table $table');
    return;
  } catch (e) {
  if (looksLikePlaceholder(supabaseUrl, anonKey)) {
      // Avoid making HTTP calls when example placeholders are used.
      return;
    }

    if (supabaseUrl != null && anonKey != null && supabaseUrl.isNotEmpty && anonKey.isNotEmpty) {
      // ignore: avoid_print
      print('upsertRows: falling back to HTTP for table $table');
      await _httpUpsert(supabaseUrl, anonKey, table, rows);
      return;
    }
    throw Exception('Could not execute builder for upsert on $table: $e');
  }
}

Future<void> deleteById(SupabaseClient client, String table, String id, {String? supabaseUrl, String? anonKey}) async {
  try {
    final builder = (client.from(table).delete().eq('id', id)) as dynamic;
    await executeBuilder(builder);
    return;
  } catch (e) {
  if (looksLikePlaceholder(supabaseUrl, anonKey)) {
      // No-op when placeholders are present.
      return;
    }

    if (supabaseUrl != null && anonKey != null && supabaseUrl.isNotEmpty && anonKey.isNotEmpty) {
      await _httpDeleteById(supabaseUrl, anonKey, table, id);
      return;
    }
    throw Exception('Could not execute builder for delete on $table: $e');
  }
}
