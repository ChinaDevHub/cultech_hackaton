import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cultech_hackaton/core/domain/heritage_category.dart';
import 'package:cultech_hackaton/core/error/failures.dart';
import 'package:cultech_hackaton/core/usecase/usecase.dart';
import 'package:cultech_hackaton/core/utils/result.dart';
import 'package:cultech_hackaton/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:cultech_hackaton/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:cultech_hackaton/features/dashboard/domain/entities/incident.dart';
import 'package:cultech_hackaton/features/dashboard/domain/usecases/get_dashboard_snapshot.dart';
import 'package:cultech_hackaton/features/dashboard/domain/usecases/watch_live_incidents.dart';
import 'package:cultech_hackaton/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetSnapshot extends Mock implements GetDashboardSnapshot {}

class _MockWatchIncidents extends Mock implements WatchLiveIncidents {}

const DashboardSnapshot _snapshot = DashboardSnapshot(
  metrics: DashboardMetrics(
    protectedDnaCount: 1240,
    activeViolations: 89,
    licensingRevenueUsd: 12400,
    dnaGrowth: 0.08,
    violationsGrowth: 0.14,
    revenueGrowth: 0.23,
    dnaTrend: <double>[1240],
    violationsTrend: <double>[89],
    revenueTrend: <double>[12400],
  ),
  recentIncidents: <Incident>[],
  platformExposure: <PlatformExposure>[
    PlatformExposure(platform: 'Midjourney', incidents: 31),
    PlatformExposure(platform: 'Suno', incidents: 22),
  ],
  coverage: <HeritageCoverage>[],
);

Incident _incident(String id, String platform) => Incident(
  id: id,
  platform: platform,
  modelVersion: 'v4',
  assetName: "'Rast' dəstgahı",
  origin: 'Azərbaycan muğamı',
  category: HeritageCategory.mugham,
  similarity: 0.95,
  status: IncidentStatus.unauthorized,
  detectedAt: DateTime(2026),
);

void main() {
  setUpAll(() => registerFallbackValue(const NoParams()));

  late _MockGetSnapshot getSnapshot;
  late _MockWatchIncidents watchIncidents;
  late StreamController<Incident> incidents;

  setUp(() {
    getSnapshot = _MockGetSnapshot();
    watchIncidents = _MockWatchIncidents();
    incidents = StreamController<Incident>();
    when(() => watchIncidents(any())).thenAnswer((_) => incidents.stream);
  });

  // Not awaited: close() on a never-listened controller never completes.
  tearDown(() => unawaited(incidents.close()));

  DashboardBloc build() =>
      DashboardBloc(getSnapshot: getSnapshot, watchIncidents: watchIncidents);

  blocTest<DashboardBloc, DashboardState>(
    'loads the snapshot, then applies live incidents',
    setUp: () => when(
      () => getSnapshot(any()),
    ).thenAnswer((_) async => const Result<DashboardSnapshot>.ok(_snapshot)),
    build: build,
    act: (DashboardBloc bloc) async {
      bloc.add(const DashboardSubscriptionRequested());
      await Future<void>.delayed(Duration.zero);
      incidents.add(_incident('INC-1', 'Suno'));
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => <Matcher>[
      isA<DashboardState>().having(
        (DashboardState s) => s.status,
        'status',
        DashboardStatus.loading,
      ),
      isA<DashboardState>()
          .having(
            (DashboardState s) => s.status,
            'status',
            DashboardStatus.ready,
          )
          .having((DashboardState s) => s.isLive, 'isLive', true),
      isA<DashboardState>()
          .having((DashboardState s) => s.incidents.single.id, 'feed', 'INC-1')
          .having(
            (DashboardState s) => s.metrics?.activeViolations,
            'violations',
            90,
          )
          .having(
            (DashboardState s) => s.platformExposure
                .firstWhere((PlatformExposure p) => p.platform == 'Suno')
                .incidents,
            'suno exposure',
            23,
          ),
    ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'surfaces snapshot failures',
    setUp: () => when(() => getSnapshot(any())).thenAnswer(
      (_) async =>
          const Result<DashboardSnapshot>.err(NetworkFailure('offline')),
    ),
    build: build,
    act: (DashboardBloc bloc) =>
        bloc.add(const DashboardSubscriptionRequested()),
    expect: () => <Matcher>[
      isA<DashboardState>().having(
        (DashboardState s) => s.status,
        'status',
        DashboardStatus.loading,
      ),
      isA<DashboardState>()
          .having(
            (DashboardState s) => s.status,
            'status',
            DashboardStatus.failure,
          )
          .having((DashboardState s) => s.failureMessage, 'message', 'offline'),
    ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'caps the live feed at feedCapacity',
    setUp: () => when(
      () => getSnapshot(any()),
    ).thenAnswer((_) async => const Result<DashboardSnapshot>.ok(_snapshot)),
    build: build,
    act: (DashboardBloc bloc) async {
      bloc.add(const DashboardSubscriptionRequested());
      await Future<void>.delayed(Duration.zero);
      for (int i = 0; i < DashboardState.feedCapacity + 3; i++) {
        incidents.add(_incident('INC-$i', 'Midjourney'));
      }
      await Future<void>.delayed(Duration.zero);
    },
    verify: (DashboardBloc bloc) {
      expect(bloc.state.incidents, hasLength(DashboardState.feedCapacity));
      expect(
        bloc.state.incidents.first.id,
        'INC-${DashboardState.feedCapacity + 2}',
      );
    },
  );
}
