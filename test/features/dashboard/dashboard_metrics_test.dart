import 'package:cultech_hackaton/core/domain/heritage_category.dart';
import 'package:cultech_hackaton/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:cultech_hackaton/features/dashboard/domain/entities/incident.dart';
import 'package:flutter_test/flutter_test.dart';

const DashboardMetrics _metrics = DashboardMetrics(
  protectedDnaCount: 1240,
  activeViolations: 89,
  licensingRevenueUsd: 12400,
  dnaGrowth: 0.08,
  violationsGrowth: 0.14,
  revenueGrowth: 0.23,
  dnaTrend: <double>[1200, 1240],
  violationsTrend: <double>[80, 89],
  revenueTrend: <double>[11000, 12400],
);

Incident _incident(IncidentStatus status, {double? fee}) => Incident(
  id: 'INC-1',
  platform: 'Midjourney',
  modelVersion: 'v6.1',
  assetName: "Qarabağ 'Xətai' naxışı",
  origin: 'Qarabağ xalçaçılıq məktəbi',
  category: HeritageCategory.carpet,
  similarity: 0.94,
  status: status,
  detectedAt: DateTime(2026),
  licenseFeeUsd: fee,
);

void main() {
  group('DashboardMetrics.applyIncident', () {
    test('unauthorized incident raises active violations and trend', () {
      final DashboardMetrics next = _metrics.applyIncident(
        _incident(IncidentStatus.unauthorized),
      );
      expect(next.activeViolations, 90);
      expect(next.violationsTrend.last, 90);
      expect(next.licensingRevenueUsd, 12400);
    });

    test('licensed incident adds license revenue', () {
      final DashboardMetrics next = _metrics.applyIncident(
        _incident(IncidentStatus.licensed, fee: 300),
      );
      expect(next.licensingRevenueUsd, 12700);
      expect(next.revenueTrend.last, 12700);
      expect(next.activeViolations, 89);
    });

    test('review / takedown incidents leave KPIs untouched', () {
      expect(
        _metrics.applyIncident(_incident(IncidentStatus.underReview)),
        _metrics,
      );
      expect(
        _metrics.applyIncident(_incident(IncidentStatus.takedownSent)),
        _metrics,
      );
    });
  });
}
