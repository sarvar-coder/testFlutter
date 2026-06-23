import 'package:flutter/material.dart';

/// Central color palette derived from the Figma design.
class AppColors {
  AppColors._();

  /// Accent green used for the Apply button and selected chips.
  static const Color accent = Color(0xFFC4EE8B);

  /// Readable green for the Filter action once filters are applied (the lime
  /// [accent] has poor contrast as text/icon on the white app bar).
  static const Color filterActive = Color(0xFF7DC023);

  /// Black pill buttons (e.g. "Clear all") and selected-chip text.
  static const Color black = Color(0xFF000000);

  /// Light grey background for the "Clear all" pill when no filters are active.
  static const Color clearAllInactive = Color(0xFFF5F6F9);

  /// Default screen background.
  static const Color background = Color(0xFFFFFFFF);

  /// Light grey used for section dividers / unselected chip backgrounds.
  static const Color divider = Color(0xFFE6E6E6);

  static const Color dragHandle = Color(0xFF161d3566);

  /// Muted grey for secondary text (company names, the match-count footer).
  static const Color textMuted = Color(0xFF8A8A8A);

  /// Primary text color.
  static const Color textPrimary = Color(0xFF111111);

  /// Blur color for the search screen when filter screen is presented
  static const Color transparent = Color(0x00000000);

  static const Color searchFieldBackground = Color(0xFFE9EBF0);
}

/// Asset paths for the app's SVG icons (see assets/images/).
class AppIcons {
  AppIcons._();

  /// Empty checkbox outline used in multi-select pickers.
  static const String checkbox = 'assets/images/checkbox.svg';

  /// Back / navigation chevron.
  static const String chevronLeft = 'assets/images/chevron_left.svg';

  /// Expand / collapse chevron for accordion sections.
  static const String chevronDown = 'assets/images/chevron_down.svg';

  /// Filter action icon.
  static const String filter = 'assets/images/filter_icon.svg';

  /// Circular "x" used for clear / close buttons.
  static const String xMarkCircle = 'assets/images/x_mark_circle.svg';
}

/// Shared corner radii from the design.
class AppRadii {
  AppRadii._();

  /// Chips / cards.
  static const double chip = 40;

  /// Pill buttons (Clear all / Apply).
  static const double button = 16;

  static const double tabBarPill = 40;

  /// Top corners of modal bottom sheets.
  static const double sheet = 32;
}

/// Reusable text styles referenced across the filter UI.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle chipLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle countFooter = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );
}

/// App-wide [ThemeData].
class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        primary: AppColors.accent,
        onPrimary: AppColors.black,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      dividerColor: AppColors.divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
        ),
      ),
    );
  }
}
