import 'package:equatable/equatable.dart';

import 'cultural_dataset.dart';
import 'pricing_plan.dart';

final class MarketplaceCatalog extends Equatable {
  const MarketplaceCatalog({required this.datasets, required this.plans});

  final List<CulturalDataset> datasets;
  final List<PricingPlan> plans;

  @override
  List<Object?> get props => <Object?>[datasets, plans];
}
