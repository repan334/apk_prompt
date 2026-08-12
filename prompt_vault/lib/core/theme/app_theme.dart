import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── THEME MODE PROVIDER ──────────────────────────────────────────────────
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class AppColors {
  AppColors._();

  // ─── BACKWARDS-COMPATIBLE STATIC COLORS ───
  static const Color bg = Color(0xFF0F1017);
  static const Color surface = Color(0xFF161824);
  static const Color card = Color(0xFF1C1E2D);
  static const Color cardElevated = Color(0xFF24273A);

  static const Color primary = Color(0xFF18181B);
  static const Color primaryLight = Color(0xFF8B84FF);
  static const Color primaryDark = Color(0xFF4B44D6);
  static const Color primaryAccent = Color(0xFF7C3AED);

  static const Color accent = Color(0xFF00D4FF);
  static const Color accentGlow = Color(0x3300D4FF);
  static const Color secondary = Color(0xFFFF6584);
  static const Color secondaryGlow = Color(0x33FF6584);

  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF8B8BA7);
  static const Color textMuted = Color(0xFF5A5A72);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color border = Color(0xFF2E3248);
  static const Color borderGlow = Color(0x556C63FF);
  static const Color divider = Color(0xFF1E1E30);

  // Category Colors
  static const Color catCoding = Color(0xFF6C63FF);
  static const Color catWriting = Color(0xFFFF6584);
  static const Color catRiset = Color(0xFF00D4FF);
  static const Color catAnalisis = Color(0xFFFFB347);
  static const Color catKreatif = Color(0xFFA8E6CF);
  static const Color catBisnis = Color(0xFFC9B1FF);
  static const Color catBelajar = Color(0xFFFFD93D);
  static const Color catLainnya = Color(0xFF8B8BA7);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFFB347);

  // ─── LIGHT MODE PALETTE (2D Minimalist Abstract) ───
  static const Color lightBg = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF0F2F6);
  static const Color lightTextPrimary = Color(0xFF12131A);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextMuted = Color(0xFF9CA3AF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightPillBg = Color(0xFF18181B);

  // ─── DARK MODE PALETTE ───
  static const Color darkBg = Color(0xFF0F1017);
  static const Color darkSurface = Color(0xFF161824);
  static const Color darkCard = Color(0xFF1C1E2D);
  static const Color darkCardElevated = Color(0xFF24273A);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF6B7280);
  static const Color darkBorder = Color(0xFF2E3248);
  static const Color darkPillBg = Color(0xFF2D3045);

  // ─── PASTEL ACCENTS ───
  static const Color pastelLime = Color(0xFFD6F498);
  static const Color pastelLavender = Color(0xFFE3D8FF);
  static const Color pastelPeach = Color(0xFFFFDEC9);
  static const Color pastelSky = Color(0xFFCFEFFF);
  static const Color pastelRose = Color(0xFFFFD4E2);
  static const Color pastelYellow = Color(0xFFFFF1A8);

  static const Color darkLime = Color(0xFF2D3B18);
  static const Color darkLavender = Color(0xFF2B2345);
  static const Color darkPeach = Color(0xFF3B2519);
  static const Color darkSky = Color(0xFF1A3345);
  static const Color darkRose = Color(0xFF3D1F2A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0F1017), Color(0xFF161824)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C1E2D), Color(0xFF24273A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGlow = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dynamic Theme Helpers (Renamed to avoid duplicate static property names)
  static Color bgOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBg : lightBg;

  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : lightSurface;

  static Color cardOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;

  static Color cardElevatedOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCardElevated : lightCardElevated;

  static Color primaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFA78BFA)
          : primary;

  static Color primaryContainerOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFA78BFA).withValues(alpha: 0.18)
          : primary.withValues(alpha: 0.08);

  static Color textPrimaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextPrimary
          : lightTextPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextSecondary
          : lightTextSecondary;

  static Color textMutedOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextMuted
          : lightTextMuted;

  static Color pillBgOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkPillBg
          : const Color(0xFFE8EAF0);

  static Color borderOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : lightBorder;
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.darkTextPrimary,
        letterSpacing: -0.8,
        height: 1.1,
      );

  // Context-aware version — resolves dark/light automatically
  static TextStyle displayLargeOf(BuildContext context) =>
      displayLarge.copyWith(color: AppColors.textPrimaryOf(context));

  // Alias with context param
  static TextStyle Function(BuildContext) get displayLargeC => displayLargeOf;

  static TextStyle get displayMedium => GoogleFonts.spaceGrotesk(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.darkTextPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle displayMediumOf(BuildContext context) =>
      displayMedium.copyWith(color: AppColors.textPrimaryOf(context));

  static TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.darkTextPrimary,
      );

  static TextStyle headingLargeOf(BuildContext context) =>
      headingLarge.copyWith(color: AppColors.textPrimaryOf(context));

  static TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      );

  static TextStyle headingMediumOf(BuildContext context) =>
      headingMedium.copyWith(color: AppColors.textPrimaryOf(context));

  static TextStyle get headingSmall => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      );

  static TextStyle headingSmallOf(BuildContext context) =>
      headingSmall.copyWith(color: AppColors.textPrimaryOf(context));

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextPrimary,
        height: 1.5,
      );

  static TextStyle bodyLargeOf(BuildContext context) =>
      bodyLarge.copyWith(color: AppColors.textPrimaryOf(context));

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextSecondary,
        height: 1.4,
      );

  static TextStyle bodyMediumOf(BuildContext context) =>
      bodyMedium.copyWith(color: AppColors.textSecondaryOf(context));

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextSecondary,
      );

  static TextStyle bodySmallOf(BuildContext context) =>
      bodySmall.copyWith(color: AppColors.textSecondaryOf(context));

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      );

  static TextStyle labelLargeOf(BuildContext context) =>
      labelLarge.copyWith(color: AppColors.textPrimaryOf(context));

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextSecondary,
      );

  static TextStyle labelMediumOf(BuildContext context) =>
      labelMedium.copyWith(color: AppColors.textSecondaryOf(context));

  static TextStyle get promptText => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextPrimary,
        height: 1.6,
      );

  static TextStyle promptTextOf(BuildContext context) =>
      promptText.copyWith(color: AppColors.textPrimaryOf(context));

  static TextStyle get captionText => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBg,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF18181B),
          secondary: Color(0xFF7C3AED),
          surface: AppColors.lightSurface,
          error: AppColors.error,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: AppColors.lightBorder, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                const BorderSide(color: AppColors.primaryAccent, width: 2),
          ),
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.lightTextMuted,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF18181B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.lightBorder,
          thickness: 1,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF3F4F6),
          secondary: Color(0xFFA78BFA),
          surface: AppColors.darkSurface,
          error: AppColors.error,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTextPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: AppColors.darkBorder, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                const BorderSide(color: Color(0xFFA78BFA), width: 2),
          ),
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.darkTextMuted,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA78BFA),
            foregroundColor: const Color(0xFF12131A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.darkBorder,
          thickness: 1,
        ),
      );
}
