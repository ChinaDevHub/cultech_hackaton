import '../../../../core/domain/heritage_category.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import 'incident_model.dart';

/// Wire format of a [DashboardSnapshot] (`GET /v1/dashboard/snapshot`).
final class DashboardSnapshotModel extends DashboardSnapshot {
  const DashboardSnapshotModel({
    required super.metrics,
    required super.recentIncidents,
    required super.platformExposure,
    required super.coverage,
  });

  factory DashboardSnapshotModel.fromJson(JsonMap json) {
    final JsonMap metrics = json['metrics'] as JsonMap;
    List<double> trend(String key) =>
        (metrics[key] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic v) => (v as num).toDouble())
            .toList(growable: false);

    return DashboardSnapshotModel(
      metrics: DashboardMetrics(
        protectedDnaCount: metrics['protected_dna_count'] as int,
        activeViolations: metrics['active_violations'] as int,
        licensingRevenueUsd: (metrics['licensing_revenue_usd'] as num)
            .toDouble(),
        dnaGrowth: (metrics['dna_growth'] as num? ?? 0).toDouble(),
        violationsGrowth: (metrics['violations_growth'] as num? ?? 0)
            .toDouble(),
        revenueGrowth: (metrics['revenue_growth'] as num? ?? 0).toDouble(),
        dnaTrend: trend('dna_trend'),
        violationsTrend: trend('violations_trend'),
        revenueTrend: trend('revenue_trend'),
      ),
      recentIncidents: (json['recent_incidents'] as List<dynamic>)
          .map((dynamic e) => IncidentModel.fromJson(e as JsonMap))
          .toList(growable: false),
      platformExposure: (json['platform_exposure'] as List<dynamic>)
          .map((dynamic e) {
            final JsonMap item = e as JsonMap;
            return PlatformExposure(
              platform: item['platform'] as String,
              incidents: item['incidents'] as int,
            );
          })
          .toList(growable: false),
      coverage: (json['coverage'] as List<dynamic>)
          .map((dynamic e) {
            final JsonMap item = e as JsonMap;
            return HeritageCoverage(
              category: HeritageCategory.fromName(item['category'] as String),
              count: item['count'] as int,
            );
          })
          .toList(growable: false),
    );
  }
}
