part of 'marketplace_bloc.dart';

sealed class MarketplaceEvent extends Equatable {
  const MarketplaceEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class MarketplaceStarted extends MarketplaceEvent {
  const MarketplaceStarted();
}

final class MarketplaceFilterChanged extends MarketplaceEvent {
  const MarketplaceFilterChanged(this.modality);

  /// `null` shows every dataset.
  final DatasetModality? modality;

  @override
  List<Object?> get props => <Object?>[modality];
}

final class MarketplaceLicenseRequested extends MarketplaceEvent {
  const MarketplaceLicenseRequested(this.dataset);

  final CulturalDataset dataset;

  @override
  List<Object?> get props => <Object?>[dataset];
}
