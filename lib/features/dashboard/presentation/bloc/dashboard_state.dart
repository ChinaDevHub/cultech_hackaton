part of 'dashboard_bloc.dart';

enum DashboardStatus { initial, loading, ready, failure }

final class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.metrics,
    this.incidents = const <Incident>[],
    this.platformExposure = const <PlatformExposure>[],
    this.coverage = const <HeritageCoverage>[],
    this.isLive = false,
    this.failureMessage,
  });

  /// Maximum number of incidents kept in the live feed.
  static const int feedCapacity = 8;

  final DashboardStatus status;
  final DashboardMetrics? metrics;
  final List<Incident> incidents;
  final List<PlatformExposure> platformExposure;
  final List<HeritageCoverage> coverage;

  /// Whether the live feed subscription is currently healthy.
  final bool isLive;
  final String? failureMessage;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardMetrics? metrics,
    List<Incident>? incidents,
    List<PlatformExposure>? platformExposure,
    List<HeritageCoverage>? coverage,
    bool? isLive,
    String? Function()? failureMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      metrics: metrics ?? this.metrics,
      incidents: incidents ?? this.incidents,
      platformExposure: platformExposure ?? this.platformExposure,
      coverage: coverage ?? this.coverage,
      isLive: isLive ?? this.isLive,
      failureMessage: failureMessage != null
          ? failureMessage()
          : this.failureMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    metrics,
    incidents,
    platformExposure,
    coverage,
    isLive,
    failureMessage,
  ];
}
