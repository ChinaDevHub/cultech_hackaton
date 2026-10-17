import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/navigation/breakpoints.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cultguard_logo.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/insight_panels.dart';
import '../widgets/live_feed_panel.dart';
import '../widgets/metrics_overview.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (_) =>
          sl<DashboardBloc>()..add(const DashboardSubscriptionRequested()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool hasSidebar = Breakpoints.useSidebar(
      MediaQuery.sizeOf(context).width,
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= Breakpoints.wideContent;
        return CustomScrollView(
          slivers: <Widget>[
            SliverSafeArea(
              sliver: SliverPadding(
                padding: Breakpoints.pagePadding(constraints.maxWidth),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: Breakpoints.maxContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _DashboardHeader(showBrand: !hasSidebar),
                          const SizedBox(height: 24),
                          MetricsOverview(wide: wide),
                          const SizedBox(height: 24),
                          if (wide)
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(flex: 3, child: LiveFeedPanel()),
                                SizedBox(width: 24),
                                Expanded(flex: 2, child: _SideColumn()),
                              ],
                            )
                          else ...const <Widget>[
                            LiveFeedPanel(),
                            SizedBox(height: 20),
                            _SideColumn(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SideColumn extends StatelessWidget {
  const _SideColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        QuickScanCard(),
        SizedBox(height: 20),
        PlatformExposurePanel(),
        SizedBox(height: 20),
        HeritageCoveragePanel(),
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.showBrand});

  final bool showBrand;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showBrand) ...<Widget>[
          const CultGuardWordmark(logoSize: 32, showTagline: false),
          const SizedBox(height: 20),
        ],
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 16,
            runSpacing: 16,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'KOMANDA MƏRKƏZİ',
                    style: text.labelMedium?.copyWith(
                      color: AppColors.gold,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('İrs Mühafizə Paneli', style: text.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Generativ AI ekosistemində mədəni irsin real-vaxt monitorinqi',
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.scanner),
                icon: const Icon(Icons.document_scanner_rounded, size: 18),
                label: const Text('Skanerə keç'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
