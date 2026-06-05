class AppConfig {
  AppConfig._();

  static const String appName = 'PromptVault';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Personal Prompt Engineering Manager';

  // Supabase — ISI DENGAN KREDENSIAL KAMU
  static const String supabaseUrl = 'https://rizzhzpjvxkmjnffawmk.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJpenpoenBqdnhrbWpuZmZhd21rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA1NDg1MjEsImV4cCI6MjA5NjEyNDUyMX0.HuDfaxfqlknF3fQcioCgMg5RcDVrDi3apXWUPqkke58';

  // App Settings
  static const int animationDurationMs = 300;
  static const int splashDurationMs = 2800;

  // Default Categories
  static const List<Map<String, String>> defaultCategories = [
    {'name': 'Coding', 'icon': '</>', 'color': '#6C63FF'},
    {'name': 'Writing', 'icon': '✍️', 'color': '#FF6584'},
    {'name': 'Riset', 'icon': '🔬', 'color': '#00D4FF'},
    {'name': 'Analisis', 'icon': '📊', 'color': '#FFB347'},
    {'name': 'Kreatif', 'icon': '🎨', 'color': '#A8E6CF'},
    {'name': 'Bisnis', 'icon': '💼', 'color': '#C9B1FF'},
    {'name': 'Belajar', 'icon': '📚', 'color': '#FFD93D'},
    {'name': 'Lainnya', 'icon': '⚡', 'color': '#8B8BA7'},
  ];
}

