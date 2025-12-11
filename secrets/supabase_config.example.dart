/// Example Supabase configuration file.
///
/// Copy this file to `secrets/supabase_config.dart` and fill in your real
/// values. Do NOT commit the `secrets/supabase_config.dart` file - it's
/// already ignored by .gitignore.

class SupabaseConfig {
  /// Your Supabase project URL, e.g. 'https://xyz.supabase.co'
  static const String url = 'hhttps://erfvwwbkzosnvfsjindu.supabase.co';

  /// Your Supabase anon/public API key.
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVyZnZ3d2Jrem9zbnZmc2ppbmR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU0NTkzNDMsImV4cCI6MjA4MTAzNTM0M30.j-UIVrCPIUgp_dTyLBYFRyGecTNmV6vic66ZORvhAPA';
}

/// Usage (example):
/// import 'package:jobtrack_uni/secrets/supabase_config.dart';
/// final url = SupabaseConfig.url;
/// final key = SupabaseConfig.anonKey;
