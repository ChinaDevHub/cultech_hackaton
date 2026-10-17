import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/entities/incident.dart';
import '../../domain/usecases/get_dashboard_snapshot.dart';
import '../../domain/usecases/watch_live_incidents.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({required this._getSnapshot, required this._watchIncidents})
    : super(const DashboardState()) {
    on<DashboardSubscriptionRequested>(
      _onSubscriptionRequested,
      transformer: restartable(),
    );
  }

  final GetDashboardSnapshot _getSnapshot;
  final WatchLiveIncidents _watchIncidents;

  Future<void> _onSubscriptionRequested(
    DashboardSubscriptionRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        status: state.metrics == null ? DashboardStatus.loading : null,
        failureMessage: () => null,
      ),
    );

    final Result<DashboardSnapshot> result = await _getSnapshot(
      const NoParams(),
    );
    switch (result) {
      case Err<DashboardSnapshot>(:final Failure failure):
        emit(
          state.copyWith(
            status: DashboardStatus.failure,
            isLive: false,
            failureMessage: () => failure.message,
          ),
        );
        return;
      case Ok<DashboardSnapshot>(:final DashboardSnapshot value):
        emit(
          state.copyWith(
            status: DashboardStatus.ready,
            metrics: value.metrics,
            incidents: value.recentIncidents
                .take(DashboardState.feedCapacity)
                .toList(growable: false),
            platformExposure: value.platformExposure,
            coverage: value.coverage,
            isLive: true,
          ),
        );
    }

    await emit.forEach<Incident>(
      _watchIncidents(const NoParams()),
      onData: _applyIncident,
      onError: (Object error, StackTrace _) => state.copyWith(
        isLive: false,
        failureMessage: () => error is Failure
            ? error.message
            : const UnexpectedFailure().message,
      ),
    );
  }

  DashboardState _applyIncident(Incident incident) {
    final List<Incident> feed = <Incident>[
      incident,
      ...state.incidents.take(DashboardState.feedCapacity - 1),
    ];

    final List<PlatformExposure> exposure = <PlatformExposure>[
      ...state.platformExposure,
    ];
    final int index = exposure.indexWhere(
      (PlatformExposure p) => p.platform == incident.platform,
    );
    if (incident.status == IncidentStatus.unauthorized) {
      if (index >= 0) {
        exposure[index] = exposure[index].increment();
      } else {
        exposure.add(
          PlatformExposure(platform: incident.platform, incidents: 1),
        );
      }
      exposure.sort(
        (PlatformExposure a, PlatformExposure b) =>
            b.incidents.compareTo(a.incidents),
      );
    }

    return state.copyWith(
      incidents: List<Incident>.unmodifiable(feed),
      metrics: state.metrics?.applyIncident(incident),
      platformExposure: List<PlatformExposure>.unmodifiable(exposure),
      isLive: true,
    );
  }
}
