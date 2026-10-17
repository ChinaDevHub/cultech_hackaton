import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/error_panel.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../bloc/dashboard_bloc.dart';
import 'metric_card.dart';

/// The three headline KPI cards, laid out responsively.
class MetricsOverview extends StatelessWidget {
  const MetricsOverview({super.key, required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (DashboardState previous, DashboardState current) =>
          previous.status != current.status ||
          previous.metrics != current.metrics,
      builder: (BuildContext context, DashboardState state) {
        final DashboardMetrics? metrics = state.metrics;
        if (metrics == null) {
          if (state.status == DashboardStatus.failure) {
            return ErrorPanel(
              message: state.failureMessage ?? 'Məlumat yüklənmədi.',
              onRetry: () => context.read<DashboardBloc>().add(
                const DashboardSubscriptionRequested(),
              ),
            );
          }
          return _layout(
            List<Widget>.generate(3, (_) => const _MetricSkeleton()),
          );
        }
        return _layout(<Widget>[
          MetricCard(
            title: 'Toplam Mədəni AI DNT İndeksi',
            value: metrics.protectedDnaCount.toDouble(),
            format: (double v) => Formatters.thousands(v.round()),
            unit: 'aktiv',
            icon: Icons.fingerprint_rounded,
            accent: AppColors.gold,
            delta: metrics.dnaGrowth,
            trend: metrics.dnaTrend,
          ),
          MetricCard(
            title: 'Aktiv Pozuntular',
            value: metrics.activeViolations.toDouble(),
            format: (double v) => Formatters.thousands(v.round()),
            unit: 'hal',
            icon: Icons.gpp_maybe_rounded,
            accent: AppColors.crimson,
            delta: metrics.violationsGrowth,
            deltaIsPositive: false,
            trend: metrics.violationsTrend,
          ),
          MetricCard(
            title: 'B2B Lisenziya Gəliri',
            value: metrics.licensingRevenueUsd,
            format: Formatters.compactUsd,
            unit: 'USD',
            icon: Icons.account_balance_wallet_rounded,
            accent: AppColors.emerald,
            delta: metrics.revenueGrowth,
            trend: metrics.revenueTrend,
          ),
        ]);
      },
    );
  }

  Widget _layout(List<Widget> cards) {
    if (wide) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int i = 0; i < cards.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: 20),
              Expanded(child: cards[i]),
            ],
          ],
        ),
      );
    }
    return Column(
      children: <Widget>[
        for (int i = 0; i < cards.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 14),
          cards[i],
        ],
      ],
    );
  }
}

class _MetricSkeleton extends StatelessWidget {
  const _MetricSkeleton();

  @override
  Widget build(BuildContext context) {
    return const GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Skeleton(height: 38, width: 38, radius: 12),
              SizedBox(width: 12),
              Expanded(child: Skeleton(height: 14)),
            ],
          ),
          SizedBox(height: 20),
          Skeleton(height: 36, width: 140),
          SizedBox(height: 16),
          Skeleton(height: 18),
        ],
      ),
    );
  }
}
