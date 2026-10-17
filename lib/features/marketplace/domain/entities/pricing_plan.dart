import 'package:equatable/equatable.dart';

enum PlanTier { starter, enterprise, sovereign }

final class PricingPlan extends Equatable {
  const PricingPlan({
    required this.tier,
    required this.name,
    required this.price,
    required this.period,
    required this.tagline,
    required this.apiQuota,
    required this.features,
    this.highlighted = false,
  });

  final PlanTier tier;
  final String name;

  /// Display price, e.g. `$49` or `Fərdi`.
  final String price;
  final String period;
  final String tagline;
  final String apiQuota;
  final List<String> features;
  final bool highlighted;

  @override
  List<Object?> get props => <Object?>[tier, name, price];
}
