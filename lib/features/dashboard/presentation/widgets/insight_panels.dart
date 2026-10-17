import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/heritage_category.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/platform_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../bloc/dashboard_bloc.dart';

/// Call-to-action that jumps straight into the AI DNA scanner.
class QuickScanCard extends StatelessWidget {
  const QuickScanCard({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return GlassPanel(
      accent: AppColors.gold,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF3A3218), Color(0xFF1A2236)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.document_scanner_rounded, color: AppColors.gold),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Yeni nümunəni yoxlayın', style: text.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Şəkil və ya audio faylı yükləyin — AI DNT saniyələr içində '
            'qlobal datasetlərlə müqayisə olunsun.',
            style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.scanner),
            icon: const Icon(Icons.bolt_rounded, size: 18),
            label: const Text('Skanerə keç'),
          ),
        ],
      ),
    );
  }
}

/// Ranking of generative-AI platforms by unauthorized uses.
class PlatformExposurePanel extends StatelessWidget {
  const PlatformExposurePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SectionHeader(
            icon: Icons.hub_rounded,
            title: 'Platformalar üzrə risk',
            subtitle: 'İcazəsiz istifadə halları',
          ),
          const SizedBox(height: 16),
          BlocSelector<DashboardBloc, DashboardState, List<PlatformExposure>>(
            selector: (DashboardState state) => state.platformExposure,
            builder: (BuildContext context, List<PlatformExposure> exposure) {
              if (exposure.isEmpty) {
                return const Column(
                  children: <Widget>[
                    Skeleton(height: 12),
                    SizedBox(height: 14),
                    Skeleton(height: 12),
                    SizedBox(height: 14),
                    Skeleton(height: 12),
                  ],
                );
              }
              final int max = exposure.first.incidents;
              return Column(
                children: <Widget>[
                  for (final PlatformExposure item in exposure.take(6))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ExposureBar(
                        label: item.platform,
                        value: item.incidents,
                        fraction: max == 0 ? 0 : item.incidents / max,
                        color: PlatformPalette.of(item.platform),
                        textTheme: text,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExposureBar extends StatelessWidget {
  const _ExposureBar({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
    required this.textTheme,
  });

  final String label;
  final int value;
  final double fraction;
  final Color color;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(label, style: textTheme.labelLarge)),
            Text(
              '$value',
              style: AppTypography.mono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                const ColoredBox(color: AppColors.navyDeep),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: fraction),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (BuildContext context, double value, Widget? _) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value.clamp(0.0, 1.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              color.withValues(alpha: 0.6),
                              color,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Composition of the protected heritage portfolio.
class HeritageCoveragePanel extends StatelessWidget {
  const HeritageCoveragePanel({super.key});

  static const Map<HeritageCategory, Color> _colors = <HeritageCategory, Color>{
    HeritageCategory.carpet: AppColors.gold,
    HeritageCategory.mugham: AppColors.cyan,
    HeritageCategory.instrument: AppColors.violet,
    HeritageCategory.ornament: AppColors.emerald,
  };

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return GlassPanel(
      child:
          BlocSelector<DashboardBloc, DashboardState, List<HeritageCoverage>>(
            selector: (DashboardState state) => state.coverage,
            builder: (BuildContext context, List<HeritageCoverage> coverage) {
              final int total = coverage.fold<int>(
                0,
                (int sum, HeritageCoverage c) => sum + c.count,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SectionHeader(
                    icon: Icons.museum_rounded,
                    title: 'Qorunan irs portfeli',
                    subtitle: 'AI DNT ilə reyestrə alınmış nümunələr',
                  ),
                  const SizedBox(height: 16),
                  if (coverage.isEmpty)
                    const Skeleton(height: 10)
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: SizedBox(
                        height: 10,
                        child: Row(
                          children: <Widget>[
                            for (final HeritageCoverage c in coverage)
                              Expanded(
                                flex: c.count,
                                child: ColoredBox(
                                  color:
                                      _colors[c.category] ?? AppColors.outline,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  for (final HeritageCoverage c in coverage)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _colors[c.category],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              c.category.label,
                              style: text.bodyMedium,
                            ),
                          ),
                          Text(
                            Formatters.thousands(c.count),
                            style: AppTypography.mono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            width: 56,
                            child: Text(
                              total == 0
                                  ? '–'
                                  : Formatters.percent(
                                      c.count / total,
                                      fractionDigits: 0,
                                    ),
                              textAlign: TextAlign.end,
                              style: AppTypography.mono(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
    );
  }
}
