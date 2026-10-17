import 'package:equatable/equatable.dart';

import '../../../../core/domain/heritage_category.dart';
import 'dashboard_metrics.dart';
import 'incident.dart';

/// Incident volume attributed to a single generative-AI platform.
final class PlatformExposure extends Equatable {
  const PlatformExposure({required this.platform, required this.incidents});

  final String platform;
  final int incidents;

  PlatformExposure increment() =>
      PlatformExposure(platform: platform, incidents: incidents + 1);

  @override
  List<Object?> get props => <Object?>[platform, incidents];
}

/// How many protected items exist per heritage family.
final class HeritageCoverage extends Equatable {
  const HeritageCoverage({required this.category, required this.count});

  final HeritageCategory category;
  final int count;

  @override
  List<Object?> get props => <Object?>[category, count];
}

/// Everything the command centre needs for its first paint.
base class DashboardSnapshot extends Equatable {
  const DashboardSnapshot({
    required this.metrics,
    required this.recentIncidents,
    required this.platformExposure,
    required this.coverage,
  });

  final DashboardMetrics metrics;
  final List<Incident> recentIncidents;
  final List<PlatformExposure> platformExposure;
  final List<HeritageCoverage> coverage;

  @override
  List<Object?> get props => <Object?>[
    metrics,
    recentIncidents,
    platformExposure,
    coverage,
  ];
}
