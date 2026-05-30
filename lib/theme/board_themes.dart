import 'package:flutter/material.dart';

/// Board visual style configuration
class BoardStyle {
  final String id;
  final String name;
  final String icon;
  final double cellBorderWidth;
  final double boxBorderWidth;
  final double cellBorderRadius;
  final bool hasInnerShadow;
  final bool hasOuterGlow;
  final double cellSpacing;
  final BoxDecoration? cellDecoration;
  final BoxDecoration? boardDecoration;

  const BoardStyle({
    required this.id,
    required this.name,
    required this.icon,
    this.cellBorderWidth = 0.5,
    this.boxBorderWidth = 2.0,
    this.cellBorderRadius = 0,
    this.hasInnerShadow = false,
    this.hasOuterGlow = false,
    this.cellSpacing = 0,
    this.cellDecoration,
    this.boardDecoration,
  });
}

/// Available board styles
class BoardStyles {
  static const classic = BoardStyle(
    id: 'classic',
    name: 'Classic',
    icon: '📋',
    cellBorderWidth: 0.5,
    boxBorderWidth: 2.0,
    cellBorderRadius: 0,
  );

  static const minimal = BoardStyle(
    id: 'minimal',
    name: 'Minimal',
    icon: '✨',
    cellBorderWidth: 0.3,
    boxBorderWidth: 1.5,
    cellBorderRadius: 0,
    cellSpacing: 1,
  );

  static const rounded = BoardStyle(
    id: 'rounded',
    name: 'Rounded',
    icon: '🔘',
    cellBorderWidth: 0.5,
    boxBorderWidth: 2.0,
    cellBorderRadius: 6,
    cellSpacing: 2,
  );

  static const paper = BoardStyle(
    id: 'paper',
    name: 'Notebook',
    icon: '📓',
    cellBorderWidth: 0.8,
    boxBorderWidth: 2.5,
    cellBorderRadius: 0,
    hasInnerShadow: true,
  );

  static const neon = BoardStyle(
    id: 'neon',
    name: 'Neon',
    icon: '💜',
    cellBorderWidth: 0.5,
    boxBorderWidth: 2.0,
    cellBorderRadius: 2,
    hasOuterGlow: true,
  );

  static const wooden = BoardStyle(
    id: 'wooden',
    name: 'Wooden',
    icon: '🪵',
    cellBorderWidth: 1.0,
    boxBorderWidth: 3.0,
    cellBorderRadius: 0,
    hasInnerShadow: true,
  );

  static const List<BoardStyle> all = [
    classic,
    minimal,
    rounded,
    paper,
    neon,
    wooden,
  ];

  static BoardStyle fromId(String id) {
    return all.firstWhere((s) => s.id == id, orElse: () => classic);
  }
}

/// Color theme configuration
class ColorTheme {
  final String id;
  final String name;
  final String icon;
  final Color primaryColor;
  final Color accentColor;
  final bool supportsDark;

  // Light mode colors
  final Color lightBg;
  final Color lightSurface;
  final Color lightSurface2;
  final Color lightBorder;
  final Color lightBorderBox;
  final Color lightText;
  final Color lightTextMuted;
  final Color lightPrimaryLight;
  final Color lightSelBg;
  final Color lightHlBg;
  final Color lightSameBg;
  final Color lightErrBg;

  // Dark mode colors
  final Color darkBg;
  final Color darkSurface;
  final Color darkSurface2;
  final Color darkBorder;
  final Color darkBorderBox;
  final Color darkText;
  final Color darkTextMuted;
  final Color darkPrimaryLight;
  final Color darkSelBg;
  final Color darkHlBg;
  final Color darkSameBg;
  final Color darkErrBg;

  const ColorTheme({
    required this.id,
    required this.name,
    required this.icon,
    required this.primaryColor,
    required this.accentColor,
    this.supportsDark = true,
    // Light defaults
    this.lightBg = const Color(0xFFF0F4FF),
    this.lightSurface = const Color(0xFFFFFFFF),
    this.lightSurface2 = const Color(0xFFEEF1F8),
    this.lightBorder = const Color(0xFFD0D7E8),
    this.lightBorderBox = const Color(0xFF4A5080),
    this.lightText = const Color(0xFF1A1D2E),
    this.lightTextMuted = const Color(0xFF7880A0),
    this.lightPrimaryLight = const Color(0xFFE8ECFF),
    this.lightSelBg = const Color(0xFFC8D4FF),
    this.lightHlBg = const Color(0xFFEEF1FF),
    this.lightSameBg = const Color(0xFFD6DEFF),
    this.lightErrBg = const Color(0xFFFDE0E2),
    // Dark defaults
    this.darkBg = const Color(0xFF0D0F1E),
    this.darkSurface = const Color(0xFF161826),
    this.darkSurface2 = const Color(0xFF1E2035),
    this.darkBorder = const Color(0xFF2A2D45),
    this.darkBorderBox = const Color(0xFF6870A8),
    this.darkText = const Color(0xFFE8EAF6),
    this.darkTextMuted = const Color(0xFF7880A8),
    this.darkPrimaryLight = const Color(0xFF1E2245),
    this.darkSelBg = const Color(0xFF2A3268),
    this.darkHlBg = const Color(0xFF1C1F38),
    this.darkSameBg = const Color(0xFF232750),
    this.darkErrBg = const Color(0xFF3D1E22),
  });
}

/// Available color themes
class ColorThemes {
  // Default Blue/Purple theme
  static const defaultTheme = ColorTheme(
    id: 'default',
    name: 'Default',
    icon: '💙',
    primaryColor: Color(0xFF4F6EF7),
    accentColor: Color(0xFFA855F7),
  );

  // Ocean Blue theme
  static const ocean = ColorTheme(
    id: 'ocean',
    name: 'Ocean',
    icon: '🌊',
    primaryColor: Color(0xFF0EA5E9),
    accentColor: Color(0xFF06B6D4),
    lightBg: Color(0xFFF0F9FF),
    lightSurface: Color(0xFFFFFFFF),
    lightSurface2: Color(0xFFE0F2FE),
    lightBorder: Color(0xFFBAE6FD),
    lightBorderBox: Color(0xFF0284C7),
    lightPrimaryLight: Color(0xFFE0F2FE),
    lightSelBg: Color(0xFFBAE6FD),
    lightHlBg: Color(0xFFF0F9FF),
    lightSameBg: Color(0xFFE0F2FE),
    darkBg: Color(0xFF0C1929),
    darkSurface: Color(0xFF0F2942),
    darkSurface2: Color(0xFF1A3A54),
    darkBorder: Color(0xFF1E4976),
    darkBorderBox: Color(0xFF38BDF8),
    darkPrimaryLight: Color(0xFF0C4A6E),
    darkSelBg: Color(0xFF0C4A6E),
    darkHlBg: Color(0xFF0F2942),
    darkSameBg: Color(0xFF164E63),
  );

  // Forest Green theme
  static const forest = ColorTheme(
    id: 'forest',
    name: 'Forest',
    icon: '🌲',
    primaryColor: Color(0xFF22C55E),
    accentColor: Color(0xFF10B981),
    lightBg: Color(0xFFF0FDF4),
    lightSurface: Color(0xFFFFFFFF),
    lightSurface2: Color(0xFFDCFCE7),
    lightBorder: Color(0xFFBBF7D0),
    lightBorderBox: Color(0xFF16A34A),
    lightPrimaryLight: Color(0xFFDCFCE7),
    lightSelBg: Color(0xFFBBF7D0),
    lightHlBg: Color(0xFFF0FDF4),
    lightSameBg: Color(0xFFDCFCE7),
    darkBg: Color(0xFF0A1F13),
    darkSurface: Color(0xFF0F2D1A),
    darkSurface2: Color(0xFF14532D),
    darkBorder: Color(0xFF166534),
    darkBorderBox: Color(0xFF4ADE80),
    darkPrimaryLight: Color(0xFF14532D),
    darkSelBg: Color(0xFF166534),
    darkHlBg: Color(0xFF0F2D1A),
    darkSameBg: Color(0xFF14532D),
  );

  // Sunset/Warm theme
  static const sunset = ColorTheme(
    id: 'sunset',
    name: 'Sunset',
    icon: '🌅',
    primaryColor: Color(0xFFF97316),
    accentColor: Color(0xFFEF4444),
    lightBg: Color(0xFFFFF7ED),
    lightSurface: Color(0xFFFFFFFF),
    lightSurface2: Color(0xFFFFEDD5),
    lightBorder: Color(0xFFFED7AA),
    lightBorderBox: Color(0xFFEA580C),
    lightPrimaryLight: Color(0xFFFFEDD5),
    lightSelBg: Color(0xFFFED7AA),
    lightHlBg: Color(0xFFFFF7ED),
    lightSameBg: Color(0xFFFFEDD5),
    darkBg: Color(0xFF1C1210),
    darkSurface: Color(0xFF2D1A15),
    darkSurface2: Color(0xFF431407),
    darkBorder: Color(0xFF7C2D12),
    darkBorderBox: Color(0xFFFB923C),
    darkPrimaryLight: Color(0xFF431407),
    darkSelBg: Color(0xFF7C2D12),
    darkHlBg: Color(0xFF2D1A15),
    darkSameBg: Color(0xFF431407),
  );

  // Lavender/Purple theme
  static const lavender = ColorTheme(
    id: 'lavender',
    name: 'Lavender',
    icon: '💜',
    primaryColor: Color(0xFF8B5CF6),
    accentColor: Color(0xFFA855F7),
    lightBg: Color(0xFFFAF5FF),
    lightSurface: Color(0xFFFFFFFF),
    lightSurface2: Color(0xFFF3E8FF),
    lightBorder: Color(0xFFE9D5FF),
    lightBorderBox: Color(0xFF7C3AED),
    lightPrimaryLight: Color(0xFFF3E8FF),
    lightSelBg: Color(0xFFE9D5FF),
    lightHlBg: Color(0xFFFAF5FF),
    lightSameBg: Color(0xFFF3E8FF),
    darkBg: Color(0xFF1A0F24),
    darkSurface: Color(0xFF2E1A47),
    darkSurface2: Color(0xFF3B0764),
    darkBorder: Color(0xFF581C87),
    darkBorderBox: Color(0xFFA78BFA),
    darkPrimaryLight: Color(0xFF3B0764),
    darkSelBg: Color(0xFF581C87),
    darkHlBg: Color(0xFF2E1A47),
    darkSameBg: Color(0xFF3B0764),
  );

  // Rose/Pink theme
  static const rose = ColorTheme(
    id: 'rose',
    name: 'Rose',
    icon: '🌸',
    primaryColor: Color(0xFFEC4899),
    accentColor: Color(0xFFF472B6),
    lightBg: Color(0xFFFDF2F8),
    lightSurface: Color(0xFFFFFFFF),
    lightSurface2: Color(0xFFFCE7F3),
    lightBorder: Color(0xFFFBCFE8),
    lightBorderBox: Color(0xFFDB2777),
    lightPrimaryLight: Color(0xFFFCE7F3),
    lightSelBg: Color(0xFFFBCFE8),
    lightHlBg: Color(0xFFFDF2F8),
    lightSameBg: Color(0xFFFCE7F3),
    darkBg: Color(0xFF1F0A14),
    darkSurface: Color(0xFF3D1427),
    darkSurface2: Color(0xFF500724),
    darkBorder: Color(0xFF831843),
    darkBorderBox: Color(0xFFF472B6),
    darkPrimaryLight: Color(0xFF500724),
    darkSelBg: Color(0xFF831843),
    darkHlBg: Color(0xFF3D1427),
    darkSameBg: Color(0xFF500724),
  );

  // Monochrome theme
  static const mono = ColorTheme(
    id: 'mono',
    name: 'Mono',
    icon: '⚫',
    primaryColor: Color(0xFF525252),
    accentColor: Color(0xFF737373),
    lightBg: Color(0xFFFAFAFA),
    lightSurface: Color(0xFFFFFFFF),
    lightSurface2: Color(0xFFF5F5F5),
    lightBorder: Color(0xFFE5E5E5),
    lightBorderBox: Color(0xFF404040),
    lightText: Color(0xFF171717),
    lightTextMuted: Color(0xFF737373),
    lightPrimaryLight: Color(0xFFF5F5F5),
    lightSelBg: Color(0xFFE5E5E5),
    lightHlBg: Color(0xFFFAFAFA),
    lightSameBg: Color(0xFFE5E5E5),
    darkBg: Color(0xFF0A0A0A),
    darkSurface: Color(0xFF171717),
    darkSurface2: Color(0xFF262626),
    darkBorder: Color(0xFF404040),
    darkBorderBox: Color(0xFFA3A3A3),
    darkText: Color(0xFFFAFAFA),
    darkTextMuted: Color(0xFFA3A3A3),
    darkPrimaryLight: Color(0xFF262626),
    darkSelBg: Color(0xFF404040),
    darkHlBg: Color(0xFF171717),
    darkSameBg: Color(0xFF262626),
  );

  static const List<ColorTheme> all = [
    defaultTheme,
    ocean,
    forest,
    sunset,
    lavender,
    rose,
    mono,
  ];

  static ColorTheme fromId(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => defaultTheme);
  }
}
