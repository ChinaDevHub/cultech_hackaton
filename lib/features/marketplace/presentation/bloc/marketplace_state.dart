part of 'marketplace_bloc.dart';

enum MarketplaceStatus { initial, loading, ready, failure }

final class MarketplaceNotice extends Equatable {
  const MarketplaceNotice({
    required this.id,
    required this.message,
    this.isError = false,
  });

  final int id;
  final String message;
  final bool isError;

  @override
  List<Object?> get props => <Object?>[id, message, isError];
}

final class MarketplaceState extends Equatable {
  const MarketplaceState({
    this.status = MarketplaceStatus.initial,
    this.datasets = const <CulturalDataset>[],
    this.plans = const <PricingPlan>[],
    this.filter,
    this.pendingIds = const <String>{},
    this.orders = const <String, LicenseOrder>{},
    this.notice,
    this.failureMessage,
  });

  final MarketplaceStatus status;
  final List<CulturalDataset> datasets;
  final List<PricingPlan> plans;
  final DatasetModality? filter;

  /// Datasets with a license request in flight.
  final Set<String> pendingIds;

  /// Completed license orders keyed by dataset id.
  final Map<String, LicenseOrder> orders;
  final MarketplaceNotice? notice;
  final String? failureMessage;

  List<CulturalDataset> get visibleDatasets => filter == null
      ? datasets
      : datasets
            .where((CulturalDataset d) => d.modality == filter)
            .toList(growable: false);

  /// Modalities that actually occur in the catalog (drives filter chips).
  List<DatasetModality> get availableModalities => DatasetModality.values
      .where(
        (DatasetModality m) =>
            datasets.any((CulturalDataset d) => d.modality == m),
      )
      .toList(growable: false);

  MarketplaceState copyWith({
    MarketplaceStatus? status,
    List<CulturalDataset>? datasets,
    List<PricingPlan>? plans,
    DatasetModality? Function()? filter,
    Set<String>? pendingIds,
    Map<String, LicenseOrder>? orders,
    MarketplaceNotice? notice,
    String? failureMessage,
  }) {
    return MarketplaceState(
      status: status ?? this.status,
      datasets: datasets ?? this.datasets,
      plans: plans ?? this.plans,
      filter: filter != null ? filter() : this.filter,
      pendingIds: pendingIds ?? this.pendingIds,
      orders: orders ?? this.orders,
      notice: notice ?? this.notice,
      failureMessage: failureMessage ?? this.failureMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    datasets,
    plans,
    filter,
    pendingIds,
    orders,
    notice,
    failureMessage,
  ];
}
