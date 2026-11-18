// ── Configuration Supabase (auto-hébergé sur le VPS) ─────────────────────────
// Source : /opt/supabase-puls/.env sur le VPS
//   url     → SUPABASE_PUBLIC_URL
//   anonKey → ANON_KEY (clé publique, protégée par les règles RLS)
// Ne jamais mettre ici la SERVICE_ROLE_KEY.
class SupabaseConfig {
  static const String url = 'https://supabase-puls.satisfactive.fr';

  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzkzODc3MTUzLCJleHAiOjE5NTE1NTcxNTN9.4_gdNjqgfFgfCqr6NjRXUN_FuAJQShS7x0Ujt_ir3tM';

  static String functionUrl(String name) => '$url/functions/v1/$name';
}
