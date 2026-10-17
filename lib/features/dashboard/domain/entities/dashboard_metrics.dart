import 'package:equatable/equatable.dart';

import 'incident.dart';

/// Headline KPIs of the command centre.
final class DashboardMetrics extends Equatable {
  const DashboardMetrics({
    required this.protectedDnaCount,
    required this.activeViolations,
    required this.licensingRevenueUsd,
    required this.dnaGrowth,
    required this.violationsGrowth,
    required this.revenueGrowth,
    required this.dnaTrend,
    required this.violationsTrend,
    required this.revenueTrend,
  });

  /// Number of heritage items with an active AI DNA fingerprint.
  final int protectedDnaCount;

  /// Open (unresolved) unauthorized uses.
  final int activeViolations;
  final double licensingRevenueUsd;

  /// Week-over-week change ratios (0.08 == +8%).
  final double dnaGrowth;
  final double violationsGrowth;
  final double revenueGrowth;

  final List<double> dnaTrend;
  final List<double> violationsTrend;
  final List<double> revenueTrend;

  /// Business rule: how a freshly detected incident moves the KPIs.
  DashboardMetrics applyIncident(Incident incident) {
    switch (incident.status) {
      case IncidentStatus.unauthorized:
        final int violations = activeViolations + 1;
        return copyWith(
          activeViolations: violations,
          violationsTrend: _withLast(violationsTrend, violations.toDouble()),
        );
      case IncidentStatus.licensed:
        final double revenue =
            licensingRevenueUsd + (incident.licenseFeeUsd ?? 0);
        return copyWith(
          licensingRevenueUsd: revenue,
          revenueTrend: _withLast(revenueTrend, revenue),
        );
      case IncidentStatus.underReview:
      case IncidentStatus.takedownSent:
        return this;
    }
  }

  static List<double> _withLast(List<double> trend, double value) {
    if (trend.isEmpty) return <double>[value];
    return List<double>.unmodifiable(<double>[
      ...trend.sublist(0, trend.length - 1),
      value,
    ]);
  }

  DashboardMetrics copyWith({
    int? protectedDnaCount,
    int? activeViolations,
    double? licensingRevenueUsd,
    List<double>? violationsTrend,
    List<double>? revenueTrend,
  }) {
    return DashboardMetrics(
      protectedDnaCount: protectedDnaCount ?? this.protectedDnaCount,
      activeViolations: activeViolations ?? this.activeViolations,
      licensingRevenueUsd: licensingRevenueUsd ?? this.licensingRevenueUsd,
      dnaGrowth: dnaGrowth,
      violationsGrowth: violationsGrowth,
      revenueGrowth: revenueGrowth,
      dnaTrend: dnaTrend,
      violationsTrend: violationsTrend ?? this.violationsTrend,
      revenueTrend: revenueTrend ?? this.revenueTrend,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    protectedDnaCount,
    activeViolations,
    licensingRevenueUsd,
    dnaGrowth,
    violationsGrowth,
    revenueGrowth,
    dnaTrend,
    violationsTrend,
    revenueTrend,
  ];
}
