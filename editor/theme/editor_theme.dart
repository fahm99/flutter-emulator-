// Flutter IDE Mobile - Editor Theme Configuration

import 'package:flutter/material.dart';
import '../constants/app_design_system.dart';

/// Editor Theme - Dark Mode (Default)
class EditorTheme {
  EditorTheme._();

  // Editor Background Colors
  static const Color editorBackground = Color(0xFF1E1E1E);
  static const Color editorLineNumber = Color(0xFF6E7681);
  static const Color editorLineNumberBackground = Color(0xFF1E1E1E);
  static const Color editorCursor = Color(0xFFAEAFAD);
  static const Color editorSelection = Color(0xFF264F78);
  static const Color editorCurrentLine = Color(0xFF2A2D2E);
  static const Color editorWhitespace = Color(0xFF404040);

  // Error and Warning Colors
  static const Color errorMarker = Color(0xFFFF453A);
  static const Color warningMarker = Color(0xFFFFD60A);
  static const Color infoMarker = Color(0xFF64D2FF);

  // Gutter Colors
  static const Color gutterBackground = Color(0xFF1E1E1E);
  static const Color gutterBorder = Color(0xFF3E3E42);

  // Find and Replace
  static const Color findMatchBackground = Color(0xFF515C6A);
  static const Color findMatchBorder = Color(0xFF6E7681);

  // Bracket Matching
  static const Color bracketMatchBackground = Color(0xFF515C6A);
  static const Color bracketMatchBorder = Color(0xFF007ACC);

  /// Get complete editor theme data
  static EditorThemeData get darkTheme => const EditorThemeData(
        background: editorBackground,
        foreground: AppColors.onSurface,
        cursorColor: editorCursor,
        selectionColor: editorSelection,
        lineNumberColor: editorLineNumber,
        lineNumberBackground: editorLineNumberBackground,
        currentLineColor: editorCurrentLine,
        errorColor: errorMarker,
        warningColor: warningMarker,
        infoColor: infoMarker,
        gutterBackground: gutterBackground,
        gutterBorder: gutterBorder,
        findMatchBackground: findMatchBackground,
        bracketMatchBackground: bracketMatchBackground,
        bracketMatchBorder: bracketMatchBorder,
      );

  /// Get light editor theme data
  static EditorThemeData get lightTheme => const EditorThemeData(
        background: Color(0xFFFFFFFF),
        foreground: Color(0xFF000000),
        cursorColor: Color(0xFF000000),
        selectionColor: Color(0xFFADD6FF),
        lineNumberColor: Color(0xFF6E7681),
        lineNumberBackground: Color(0xFFF5F5F5),
        currentLineColor: Color(0xFFFAFAFA),
        errorColor: Color(0xFFD32F2F),
        warningColor: Color(0xFFF57C00),
        infoColor: Color(0xFF1976D2),
        gutterBackground: Color(0xFFF5F5F5),
        gutterBorder: Color(0xFFE0E0E0),
        findMatchBackground: Color(0xFFA8AC94),
        bracketMatchBackground: Color(0xFFADD6FF),
        bracketMatchBorder: Color(0xFF007ACC),
      );
}

/// Editor Theme Data
class EditorThemeData {
  final Color background;
  final Color foreground;
  final Color cursorColor;
  final Color selectionColor;
  final Color lineNumberColor;
  final Color lineNumberBackground;
  final Color currentLineColor;
  final Color errorColor;
  final Color warningColor;
  final Color infoColor;
  final Color gutterBackground;
  final Color gutterBorder;
  final Color findMatchBackground;
  final Color bracketMatchBackground;
  final Color bracketMatchBorder;

  const EditorThemeData({
    required this.background,
    required this.foreground,
    required this.cursorColor,
    required this.selectionColor,
    required this.lineNumberColor,
    required this.lineNumberBackground,
    required this.currentLineColor,
    required this.errorColor,
    required this.warningColor,
    required this.infoColor,
    required this.gutterBackground,
    required this.gutterBorder,
    required this.findMatchBackground,
    required this.bracketMatchBackground,
    required this.bracketMatchBorder,
  });
}

/// Syntax Theme - Defines syntax highlighting colors
class SyntaxTheme {
  final Color keyword;
  final Color type;
  final Color string;
  final Color function;
  final Color comment;
  final Color number;
  final Color bracket;
  final Color variable;
  final Color className;
  final Color operator;

  const SyntaxTheme({
    required this.keyword,
    required this.type,
    required this.string,
    required this.function,
    required this.comment,
    required this.number,
    required this.bracket,
    required this.variable,
    required this.className,
    required this.operator,
  });

  static const SyntaxTheme dark = SyntaxTheme(
    keyword: AppColors.syntaxKeyword,
    type: AppColors.syntaxType,
    string: AppColors.syntaxString,
    function: AppColors.syntaxFunction,
    comment: AppColors.syntaxComment,
    number: AppColors.syntaxNumber,
    bracket: AppColors.syntaxBracket,
    variable: AppColors.syntaxVariable,
    className: AppColors.syntaxClass,
    operator: AppColors.syntaxOperator,
  );

  static const SyntaxTheme light = SyntaxTheme(
    keyword: Color(0xFF0000FF),
    type: Color(0xFF267F99),
    string: Color(0xFFA31515),
    function: Color(0xFF795E26),
    comment: Color(0xFF008000),
    number: Color(0xFF098658),
    bracket: Color(0xFF000000),
    variable: Color(0xFF001080),
    className: Color(0xFF267F99),
    operator: Color(0xFF000000),
  );
}