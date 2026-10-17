import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/heritage_category.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/platform_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/pulse_dot.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/incident.dart';
import '../bloc/dashboard_bloc.dart';

/// Real-time stream of detected infringements across generative-AI models.
class LiveFeedPanel extends StatelessWidget {
  const LiveFeedPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionHeader(
            icon: Icons.radar_rounded,
            title: 'Real-Time İnsident Axını',
            subtitle: 'Qlobal AI modellərində aşkarlanan mənimsəmələr',
            trailing: BlocSelector<DashboardBloc, DashboardState, bool>(
              selector: (DashboardState state) => state.isLive,
              builder: (BuildContext context, bool isLive) =>
                  _LiveIndicator(isLive: isLive),
            ),
          ),
          const SizedBox(height: 14),
          BlocBuilder<DashboardBloc, DashboardState>(
            buildWhen: (DashboardState previous, DashboardState current) =>
                previous.incidents != current.incidents ||
                previous.status != current.status,
            builder: (BuildContext context, DashboardState state) {
              if (state.status == DashboardStatus.loading ||
                  state.status == DashboardStatus.initial) {
                return const _FeedSkeleton();
              }
              if (state.incidents.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Hələ ki, insident aşkarlanmayıb.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool compact = constraints.maxWidth < 560;
                  return Column(
                    children: <Widget>[
                      for (int i = 0; i < state.incidents.length; i++)
                        FadeSlideIn(
                          key: ValueKey<String>(state.incidents[i].id),
                          delay: Duration(milliseconds: i * 40),
                          offset: const Offset(0, -0.25),
                          highlight: i == 0
                              ? _statusColor(state.incidents[i].status)
                              : null,
                          child: IncidentTile(
                            incident: state.incidents[i],
                            compact: compact,
                            showDivider: i < state.incidents.length - 1,
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

Color _statusColor(IncidentStatus status) {
  return switch (status) {
    IncidentStatus.unauthorized => AppColors.crimson,
    IncidentStatus.underReview => AppColors.amber,
    IncidentStatus.takedownSent => AppColors.cyan,
    IncidentStatus.licensed => AppColors.emerald,
  };
}

IconData _categoryIcon(HeritageCategory category) {
  return switch (category) {
    HeritageCategory.carpet => Icons.grid_on_rounded,
    HeritageCategory.mugham => Icons.graphic_eq_rounded,
    HeritageCategory.instrument => Icons.music_note_rounded,
    HeritageCategory.ornament => Icons.auto_awesome_mosaic_rounded,
  };
}

class _LiveIndicator extends StatelessWidget {
  const _LiveIndicator({required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final Color color = isLive ? AppColors.crimson : AppColors.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isLive)
          PulseDot(color: color, size: 8)
        else
          Icon(Icons.pause_circle_outline_rounded, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          isLive ? 'CANLI' : 'DAYANIB',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class IncidentTile extends StatelessWidget {
  const IncidentTile({
    super.key,
    required this.incident,
    required this.compact,
    this.showDivider = true,
  });

  final Incident incident;
  final bool compact;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color platformColor = PlatformPalette.of(incident.platform);
    final Color statusColor = _statusColor(incident.status);
    final Widget badge = StatusBadge(
      label: incident.status.label,
      color: statusColor,
      dense: compact,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.outlineSoft))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: platformColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: platformColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                PlatformPalette.monogram(incident.platform),
                style: text.labelLarge?.copyWith(
                  color: platformColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: incident.platformLabel,
                          style: TextStyle(
                            color: platformColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: ' — '),
                        TextSpan(
                          text: incident.assetName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(
                          text: ' aşkarlandı',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    style: text.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      _SimilarityPill(similarity: incident.similarity),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            _categoryIcon(incident.category),
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              incident.origin,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        Formatters.clock(incident.detectedAt),
                        style: AppTypography.mono(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (compact) badge,
                    ],
                  ),
                ],
              ),
            ),
            if (!compact) ...<Widget>[const SizedBox(width: 12), badge],
          ],
        ),
      ),
    );
  }
}

class _SimilarityPill extends StatelessWidget {
  const _SimilarityPill({required this.similarity});

  final double similarity;

  @override
  Widget build(BuildContext context) {
    final Color color = similarity >= 0.9 ? AppColors.crimson : AppColors.amber;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.navyDeep,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          '${Formatters.percent(similarity)} oxşarlıq',
          style: AppTypography.mono(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(
        5,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: <Widget>[
              Skeleton(height: 40, width: 40, radius: 12),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Skeleton(height: 14),
                    SizedBox(height: 8),
                    Skeleton(height: 10, width: 180),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
