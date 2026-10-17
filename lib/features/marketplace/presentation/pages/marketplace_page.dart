import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/navigation/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_panel.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../domain/entities/cultural_dataset.dart';
import '../../domain/entities/pricing_plan.dart';
import '../bloc/api_key_cubit.dart';
import '../bloc/marketplace_bloc.dart';
import '../widgets/api_portal.dart';
import '../widgets/dataset_card.dart';
import '../widgets/pricing_section.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<MarketplaceBloc>(
          create: (_) => sl<MarketplaceBloc>()..add(const MarketplaceStarted()),
        ),
        BlocProvider<ApiKeyCubit>(create: (_) => sl<ApiKeyCubit>()),
      ],
      child: const MarketplaceView(),
    );
  }
}

class MarketplaceView extends StatelessWidget {
  const MarketplaceView({super.key});

  void _onPlanSelected(BuildContext context, PricingPlan plan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '"${plan.name}" planı üzrə sorğunuz qəbul edildi — '
            'komandamız 24 saat ərzində əlaqə saxlayacaq.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MarketplaceBloc, MarketplaceState>(
      listenWhen: (MarketplaceState previous, MarketplaceState current) =>
          current.notice != null && previous.notice != current.notice,
      listener: (BuildContext context, MarketplaceState state) {
        final MarketplaceNotice notice = state.notice!;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: <Widget>[
                  Icon(
                    notice.isError
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_rounded,
                    color: notice.isError
                        ? AppColors.crimson
                        : AppColors.emerald,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(notice.message)),
                ],
              ),
            ),
          );
      },
      child: LayoutBuilder(
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
                            const _MarketplaceHeader(),
                            const SizedBox(height: 20),
                            const _ImpactStrip(),
                            const SizedBox(height: 28),
                            const _DatasetSection(),
                            const SizedBox(height: 36),
                            const SectionHeader(
                              icon: Icons.api_rounded,
                              title: 'Developer API Portalı',
                              subtitle:
                                  'GameDev mühərrikləri və AI təlim boru kəmərləri üçün inteqrasiya',
                            ),
                            const SizedBox(height: 16),
                            if (wide)
                              const IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: ApiKeyGeneratorCard(),
                                    ),
                                    SizedBox(width: 20),
                                    Expanded(
                                      flex: 2,
                                      child: ApiQuickstartCard(),
                                    ),
                                  ],
                                ),
                              )
                            else ...const <Widget>[
                              ApiKeyGeneratorCard(),
                              SizedBox(height: 16),
                              ApiQuickstartCard(),
                            ],
                            const SizedBox(height: 36),
                            const SectionHeader(
                              icon: Icons.workspace_premium_rounded,
                              title: 'Qiymət Planları',
                              subtitle:
                                  'Hər lisenziya gəlirinin 30%-i irs icmalarına yönəldilir',
                            ),
                            const SizedBox(height: 16),
                            BlocSelector<
                              MarketplaceBloc,
                              MarketplaceState,
                              List<PricingPlan>
                            >(
                              selector: (MarketplaceState state) => state.plans,
                              builder:
                                  (
                                    BuildContext context,
                                    List<PricingPlan> plans,
                                  ) {
                                    if (plans.isEmpty) {
                                      return const Skeleton(
                                        height: 320,
                                        radius: 16,
                                      );
                                    }
                                    return PricingSection(
                                      plans: plans,
                                      onSelect: (PricingPlan plan) =>
                                          _onPlanSelected(context, plan),
                                    );
                                  },
                            ),
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
      ),
    );
  }
}

class _MarketplaceHeader extends StatelessWidget {
  const _MarketplaceHeader();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'B2B MARKETPLACE & API',
          style: text.labelMedium?.copyWith(
            color: AppColors.gold,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text('Təsdiqlənmiş Mədəni Datasetlər', style: text.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'GameDev studiyaları və AI modellərinin təlimi üçün hüquqi təmiz, '
          'etik mənbəli Azərbaycan irsi datasetləri.',
          style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ImpactStrip extends StatelessWidget {
  const _ImpactStrip();

  static const List<(IconData, String, String)> _facts =
      <(IconData, String, String)>[
        (Icons.dataset_rounded, '6', 'kurasiya olunmuş dataset'),
        (Icons.collections_rounded, '40K+', 'lisenziyalı nümunə'),
        (Icons.gavel_rounded, '100%', 'hüquqi təmiz mənbə'),
        (Icons.volunteer_activism_rounded, '30%', 'gəlir icmalara'),
      ];

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        for (final (IconData icon, String value, String label) in _facts)
          GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            radius: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 18, color: AppColors.gold),
                const SizedBox(width: 8),
                Text(value, style: text.titleSmall),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: text.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DatasetSection extends StatelessWidget {
  const _DatasetSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketplaceBloc, MarketplaceState>(
      builder: (BuildContext context, MarketplaceState state) {
        final MarketplaceBloc bloc = context.read<MarketplaceBloc>();
        if (state.status == MarketplaceStatus.failure) {
          return ErrorPanel(
            message: state.failureMessage ?? 'Kataloq yüklənmədi.',
            onRetry: () => bloc.add(const MarketplaceStarted()),
          );
        }
        final bool loading = state.status != MarketplaceStatus.ready;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _FilterChip(
                    label: 'Hamısı',
                    selected: state.filter == null,
                    onSelected: () =>
                        bloc.add(const MarketplaceFilterChanged(null)),
                  ),
                  for (final DatasetModality modality
                      in state.availableModalities)
                    _FilterChip(
                      label: modality.label,
                      icon: modalityIcon(modality),
                      selected: state.filter == modality,
                      onSelected: () =>
                          bloc.add(MarketplaceFilterChanged(modality)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                const double spacing = 20;
                final int columns = constraints.maxWidth >= 1080
                    ? 3
                    : constraints.maxWidth >= 640
                    ? 2
                    : 1;
                final double width =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                if (loading) {
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: List<Widget>.generate(
                      columns,
                      (_) => SizedBox(
                        width: width,
                        child: const Skeleton(height: 420, radius: 16),
                      ),
                    ),
                  );
                }

                final List<CulturalDataset> datasets = state.visibleDatasets;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: <Widget>[
                    for (int i = 0; i < datasets.length; i++)
                      SizedBox(
                        width: width,
                        child: FadeSlideIn(
                          key: ValueKey<String>(
                            '${state.filter}-${datasets[i].id}',
                          ),
                          delay: Duration(milliseconds: 60 * i),
                          child: DatasetCard(
                            dataset: datasets[i],
                            isPending: state.pendingIds.contains(
                              datasets[i].id,
                            ),
                            order: state.orders[datasets[i].id],
                            onLicense: () => bloc.add(
                              MarketplaceLicenseRequested(datasets[i]),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        avatar: icon == null
            ? null
            : Icon(
                icon,
                size: 16,
                color: selected ? AppColors.goldLight : AppColors.textSecondary,
              ),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
