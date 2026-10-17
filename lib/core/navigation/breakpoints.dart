import 'package:material_ui/material_ui.dart';

/// Responsive breakpoints shared by the shell and page layouts.
abstract final class Breakpoints {
  /// At and above this width the app uses the side navigation.
  static const double sidebar = 800;

  /// At and above this width the sidebar shows labels.
  static const double sidebarExtended = 1180;

  /// Content width above which pages switch to multi-column layouts.
  static const double wideContent = 900;

  static const double maxContentWidth = 1320;

  static bool useSidebar(double width) => width >= sidebar;

  static EdgeInsets pagePadding(double width) {
    if (width >= 1100) return const EdgeInsets.fromLTRB(36, 32, 36, 40);
    if (width >= 600) return const EdgeInsets.fromLTRB(24, 24, 24, 32);
    return const EdgeInsets.fromLTRB(16, 16, 16, 28);
  }
}
