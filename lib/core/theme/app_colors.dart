import 'dart:ui';

/// CultGuard brand palette.
///
/// Deep navy/slate surfaces carry the "digital vault" feel, cultural gold is
/// the heritage accent, emerald marks verified/licensed content and crimson
/// marks infringements. Cyan is reserved for AI/vector visualisations.
abstract final class AppColors {
  // Surfaces
  static const Color navy = Color(0xFF0F172A);
  static const Color navyDeep = Color(0xFF0A1020);
  static const Color slate = Color(0xFF1E293B);
  static const Color slateElevated = Color(0xFF243247);
  static const Color outline = Color(0xFF334155);
  static const Color outlineSoft = Color(0x33475569);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Brand accents
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3D98B);
  static const Color goldDeep = Color(0xFF9C7C1C);
  static const Color emerald = Color(0xFF10B981);
  static const Color crimson = Color(0xFFEF4444);
  static const Color amber = Color(0xFFF59E0B);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color violet = Color(0xFF8B5CF6);

  static const List<Color> goldGradient = <Color>[goldLight, gold, goldDeep];
}
