import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../domain/entities/pricing_plan.dart';

class PricingSection extends StatelessWidget {
  const PricingSection({
    super.key,
    required this.plans,
    required this.onSelect,
  });

  final List<PricingPlan> plans;
  final ValueChanged<PricingPlan> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 820;
        final List<Widget> cards = <Widget>[
          for (final PricingPlan plan in plans)
            PricingPlanCard(
              plan: plan,
              fillHeight: !compact,
              onSelect: () => onSelect(plan),
            ),
        ];
        if (compact) {
          return Column(
            children: <Widget>[
              for (int i = 0; i < cards.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: 16),
                cards[i],
              ],
            ],
          );
        }
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
      },
    );
  }
}

class PricingPlanCard extends StatelessWidget {
  const PricingPlanCard({
    super.key,
    required this.plan,
    required this.onSelect,
    this.fillHeight = false,
  });

  final PricingPlan plan;
  final VoidCallback onSelect;

  /// Pushes the CTA to the bottom when the card has a bounded height
  /// (side-by-side layout); must be false inside unbounded scroll views.
  final bool fillHeight;

  Color get _accent => switch (plan.tier) {
    PlanTier.starter => AppColors.cyan,
    PlanTier.enterprise => AppColors.gold,
    PlanTier.sovereign => AppColors.emerald,
  };

  String get _cta => switch (plan.tier) {
    PlanTier.starter => 'Başla',
    PlanTier.enterprise => 'Satış komandası ilə əlaqə',
    PlanTier.sovereign => 'Təklif al',
  };

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color accent = _accent;
    return GlassPanel(
      accent: plan.highlighted ? accent : null,
      gradient: plan.highlighted
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFF2A2716), Color(0xF2131C2E)],
            )
          : null,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(plan.name, style: text.titleLarge?.copyWith(color: accent)),
              const Spacer(),
              if (plan.highlighted)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      'Ən populyar',
                      style: text.labelSmall?.copyWith(
                        color: AppColors.navyDeep,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            plan.tagline,
            style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(plan.price, style: text.displaySmall),
              const SizedBox(width: 4),
              Text(
                plan.period,
                style: text.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(plan.apiQuota, style: text.labelMedium?.copyWith(color: accent)),
          const SizedBox(height: 18),
          for (final String feature in plan.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.check_circle_rounded, size: 17, color: accent),
                  const SizedBox(width: 10),
                  Expanded(child: Text(feature, style: text.bodyMedium)),
                ],
              ),
            ),
          if (fillHeight) const Spacer(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: plan.highlighted
                ? FilledButton(onPressed: onSelect, child: Text(_cta))
                : OutlinedButton(onPressed: onSelect, child: Text(_cta)),
          ),
        ],
      ),
    );
  }
}
