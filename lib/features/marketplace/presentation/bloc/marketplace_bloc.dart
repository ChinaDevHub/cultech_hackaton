import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/cultural_dataset.dart';
import '../../domain/entities/license_order.dart';
import '../../domain/entities/marketplace_catalog.dart';
import '../../domain/entities/pricing_plan.dart';
import '../../domain/usecases/marketplace_usecases.dart';

part 'marketplace_event.dart';
part 'marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  MarketplaceBloc({required this._getCatalog, required this._requestLicense})
    : super(const MarketplaceState()) {
    on<MarketplaceStarted>(_onStarted, transformer: droppable());
    on<MarketplaceFilterChanged>(_onFilterChanged);
    on<MarketplaceLicenseRequested>(_onLicenseRequested);
  }

  final GetMarketplaceCatalog _getCatalog;
  final RequestDatasetLicense _requestLicense;
  int _noticeSeq = 0;

  Future<void> _onStarted(
    MarketplaceStarted event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(state.copyWith(status: MarketplaceStatus.loading));
    final Result<MarketplaceCatalog> result = await _getCatalog(
      const NoParams(),
    );
    switch (result) {
      case Ok<MarketplaceCatalog>(:final MarketplaceCatalog value):
        emit(
          state.copyWith(
            status: MarketplaceStatus.ready,
            datasets: value.datasets,
            plans: value.plans,
          ),
        );
      case Err<MarketplaceCatalog>(:final Failure failure):
        emit(
          state.copyWith(
            status: MarketplaceStatus.failure,
            failureMessage: failure.message,
          ),
        );
    }
  }

  void _onFilterChanged(
    MarketplaceFilterChanged event,
    Emitter<MarketplaceState> emit,
  ) {
    emit(state.copyWith(filter: () => event.modality));
  }

  Future<void> _onLicenseRequested(
    MarketplaceLicenseRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    final String id = event.dataset.id;
    if (state.pendingIds.contains(id) || state.orders.containsKey(id)) return;

    emit(state.copyWith(pendingIds: <String>{...state.pendingIds, id}));
    final Result<LicenseOrder> result = await _requestLicense(event.dataset);
    final Set<String> pending = <String>{...state.pendingIds}..remove(id);
    switch (result) {
      case Ok<LicenseOrder>(:final LicenseOrder value):
        emit(
          state.copyWith(
            pendingIds: pending,
            orders: <String, LicenseOrder>{...state.orders, id: value},
            notice: MarketplaceNotice(
              id: ++_noticeSeq,
              message: 'Lisenziya sorğusu qəbul edildi · ${value.id}',
            ),
          ),
        );
      case Err<LicenseOrder>(:final Failure failure):
        emit(
          state.copyWith(
            pendingIds: pending,
            notice: MarketplaceNotice(
              id: ++_noticeSeq,
              message: failure.message,
              isError: true,
            ),
          ),
        );
    }
  }
}
