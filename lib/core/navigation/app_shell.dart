import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../widgets/cultguard_logo.dart';
import '../widgets/heritage_backdrop.dart';
import '../widgets/pulse_dot.dart';
import 'breakpoints.dart';

class _Destination {
  const _Destination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.shortLabel,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String shortLabel;
}

const List<_Destination> _destinations = <_Destination>[
  _Destination(
    icon: Icons.space_dashboard_outlined,
    selectedIcon: Icons.space_dashboard_rounded,
    label: 'İdarə Paneli',
    shortLabel: 'Panel',
  ),
  _Destination(
    icon: Icons.document_scanner_outlined,
    selectedIcon: Icons.document_scanner_rounded,
    label: 'AI DNT Skaner',
    shortLabel: 'Skaner',
  ),
  _Destination(
    icon: Icons.storefront_outlined,
    selectedIcon: Icons.storefront_rounded,
    label: 'B2B Marketplace',
    shortLabel: 'Marketplace',
  ),
];

/// Responsive chrome around the three main branches.
///
/// * ≥ 800 px: custom sidebar (collapsed rail until 1180 px, then extended).
/// * < 800 px: Material 3 bottom navigation bar.
///
/// The body keeps a stable position in the element tree across layout
/// switches, so resizing a browser window never loses branch state.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _select(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool sidebar = Breakpoints.useSidebar(width);
    final Widget body = _BranchFade(
      index: navigationShell.currentIndex,
      child: navigationShell,
    );

    return Scaffold(
      body: HeritageBackdrop(
        child: Row(
          children: <Widget>[
            if (sidebar)
              _Sidebar(
                extended: width >= Breakpoints.sidebarExtended,
                selectedIndex: navigationShell.currentIndex,
                onSelect: _select,
              ),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: sidebar
          ? null
          : NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _select,
              destinations: <Widget>[
                for (final _Destination d in _destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.shortLabel,
                    tooltip: d.label,
                  ),
              ],
            ),
    );
  }
}

/// Cross-fades branches on tab switch without rebuilding their subtrees.
class _BranchFade extends StatefulWidget {
  const _BranchFade({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_BranchFade> createState() => _BranchFadeState();
}

class _BranchFadeState extends State<_BranchFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: 1,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void didUpdateWidget(_BranchFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) _controller.forward(from: 0.15);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.extended,
    required this.selectedIndex,
    required this.onSelect,
  });

  final bool extended;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: extended ? 264 : 88,
      decoration: BoxDecoration(
        color: AppColors.navyDeep.withValues(alpha: 0.92),
        border: const Border(right: BorderSide(color: AppColors.outlineSoft)),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: extended ? 18 : 12,
            vertical: 22,
          ),
          child: Column(
            crossAxisAlignment: extended
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: <Widget>[
              if (extended)
                const CultGuardWordmark(logoSize: 40)
              else
                const Hero(
                  tag: CultGuardLogo.heroTag,
                  child: CultGuardLogo(size: 42),
                ),
              const SizedBox(height: 36),
              if (extended)
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 10),
                  child: Text(
                    'NAVİQASİYA',
                    style: text.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.6,
                    ),
                  ),
                ),
              for (int i = 0; i < _destinations.length; i++)
                _SidebarItem(
                  destination: _destinations[i],
                  selected: i == selectedIndex,
                  extended: extended,
                  onTap: () => onSelect(i),
                ),
              const Spacer(),
              _SystemStatus(extended: extended),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color color = selected
        ? AppColors.goldLight
        : AppColors.textSecondary;
    final Widget item = Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: extended ? 14 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: selected
                  ? AppColors.gold.withValues(alpha: 0.12)
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? AppColors.gold.withValues(alpha: 0.35)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: extended
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  color: selected ? AppColors.gold : AppColors.textSecondary,
                  size: 22,
                ),
                if (extended) ...<Widget>[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelLarge?.copyWith(
                        color: color,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: selected ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: extended ? item : Tooltip(message: destination.label, child: item),
    );
  }
}

class _SystemStatus extends StatelessWidget {
  const _SystemStatus({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    if (!extended) {
      return const Tooltip(
        message: 'Qoruma aktivdir',
        child: PulseDot(color: AppColors.emerald, size: 9),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          const PulseDot(color: AppColors.emerald, size: 8),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Qoruma aktivdir',
                  style: text.labelLarge?.copyWith(color: AppColors.emerald),
                ),
                Text(
                  '12 AI platforması izlənilir',
                  style: text.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
