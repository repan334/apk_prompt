class AppConfig {
  AppConfig._();

  static const String appName = 'PromptVault';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Personal Prompt Engineering Manager';

  // Supabase — ISI DENGAN KREDENSIAL KAMU
  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // App Settings
  static const int animationDurationMs = 300;
  static const int splashDurationMs = 2800;

  // Default Categories
  static const List<Map<String, String>> defaultCategories = [
    {'name': 'Coding', 'icon': 'code', 'color': '#6C63FF'},
    {'name': 'Writing', 'icon': 'edit', 'color': '#FF6584'},
    {'name': 'Riset', 'icon': 'search', 'color': '#00D4FF'},
    {'name': 'Analisis', 'icon': 'chart', 'color': '#FFB347'},
    {'name': 'Kreatif', 'icon': 'brush', 'color': '#A8E6CF'},
    {'name': 'Bisnis', 'icon': 'briefcase', 'color': '#C9B1FF'},
    {'name': 'Belajar', 'icon': 'book', 'color': '#FFD93D'},
    {'name': 'Lainnya', 'icon': 'flash', 'color': '#8B8BA7'},
  ];
}

