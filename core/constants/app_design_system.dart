// Flutter IDE Mobile - Design System Constants
// Based on the provided UI/UX design specifications

import 'package:flutter/material.dart';

/// Design System Color Palette - Dark Mode Default
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF007ACC);
  static const Color primaryContainer = Color(0xFF007ACC);
  static const Color onPrimary = Color(0xFF003258);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
  static const Color primaryFixed = Color(0xFFD1E4FF);
  static const Color primaryFixedDim = Color(0xFF9FCAFF);

  // Secondary Colors
  static const Color secondary = Color(0xFF61DAC1);
  static const Color secondaryContainer = Color(0xFF13A38B);
  static const Color onSecondary = Color(0xFF00382E);
  static const Color onSecondaryContainer = Color(0xFF003028);
  static const Color secondaryFixed = Color(0xFF80F7DC);
  static const Color secondaryFixedDim = Color(0xFF61DAC1);

  // Tertiary Colors
  static const Color tertiary = Color(0xFFFFB784);
  static const Color tertiaryContainer = Color(0xFFB95E01);
  static const Color onTertiary = Color(0xFF4F2500);
  static const Color onTertiaryContainer = Color(0xFFFFFFFF);
  static const Color tertiaryFixed = Color(0xFFFFDCC6);
  static const Color tertiaryFixedDim = Color(0xFFFFB784);

  // Surface Colors
  static const Color surface = Color(0xFF101419);
  static const Color surfaceDim = Color(0xFF101419);
  static const Color surfaceContainer = Color(0xFF1C2025);
  static const Color surfaceContainerLow = Color(0xFF181C21);
  static const Color surfaceContainerHigh = Color(0xFF272A30);
  static const Color surfaceContainerHighest = Color(0xFF31353B);
  static const Color surfaceContainerLowest = Color(0xFF0B0E13);
  static const Color surfaceBright = Color(0xFF36393F);
  static const Color surfaceTint = Color(0xFF9FCAFF);

  // Background Colors
  static const Color background = Color(0xFF101419);
  static const Color onBackground = Color(0xFFE0E2EA);

  // Text Colors
  static const Color onSurface = Color(0xFFE0E2EA);
  static const Color onSurfaceVariant = Color(0xFFC0C7D3);
  static const Color onInverseSurface = Color(0xFF2D3136);
  static const Color inverseSurface = Color(0xFFE0E2EA);
  static const Color inversePrimary = Color(0xFF0061A4);

  // Border Colors
  static const Color outline = Color(0xFF8A919D);
  static const Color outlineVariant = Color(0xFF404751);
  static const Color border = Color(0xFF3E3E42);

  // Error Colors
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Syntax Highlighting Colors
  static const Color syntaxKeyword = Color(0xFF569CD6);
  static const Color syntaxType = Color(0xFF4EC9B0);
  static const Color syntaxString = Color(0xFFCE9178);
  static const Color syntaxFunction = Color(0xFFDCDCAA);
  static const Color syntaxComment = Color(0xFF6A9955);
  static const Color syntaxNumber = Color(0xFFB5CEA8);
  static const Color syntaxBracket = Color(0xFFFFD700);
  static const Color syntaxOperator = Color(0xFFD4D4D4);
  static const Color syntaxVariable = Color(0xFF9CDCFE);
  static const Color syntaxClass = Color(0xFF4EC9B0);

  // Terminal Colors
  static const Color terminalBackground = Color(0xFF0B0E13);
  static const Color terminalText = Color(0xFFC0C7D3);
  static const Color terminalSuccess = Color(0xFF30D158);
  static const Color terminalError = Color(0xFFFF453A);
  static const Color terminalWarning = Color(0xFFFFD60A);
  static const Color terminalInfo = Color(0xFF64D2FF);
}

/// Design System Typography
class AppTypography {
  AppTypography._();

  // Font Families
  static const String uiFont = 'Inter';
  static const String codeFont = 'JetBrains Mono';

  // Code Font Sizes (from design system)
  static const TextStyle codeMd = TextStyle(
    fontFamily: codeFont,
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle codeSm = TextStyle(
    fontFamily: codeFont,
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  // UI Font Sizes
  static const TextStyle labelMd = TextStyle(
    fontFamily: uiFont,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: uiFont,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: uiFont,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: uiFont,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
}

/// Design System Spacing
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double base = 4.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double gutter = 12.0;
  static const double touchTargetMin = 44.0;
}

/// Design System Border Radius
class AppRadius {
  AppRadius._();

  static const double DEFAULT = 4.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double full = 12.0;
}