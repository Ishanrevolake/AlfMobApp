class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gmevwphjxcnrdydfsqgb.supabase.co',
  );
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_-hW0d3-to5Nkbbe-6q-JBQ_TfO82KMQ',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
