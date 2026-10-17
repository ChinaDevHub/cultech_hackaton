import 'dart:async';
import 'dart:math' as math;

import '../../../../core/domain/heritage_category.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/entities/incident.dart';
import 'dashboard_data_source.dart';

typedef _Asset = ({String name, String origin, HeritageCategory category});
typedef _Platform = ({String name, String version});

/// Offline simulation of the CultGuard detection network.
///
/// Produces realistic, varied incidents at a human-readable cadence so the
/// command centre feels alive during a live demo without any backend.
final class DashboardDemoDataSource implements DashboardDataSource {
  DashboardDemoDataSource({
    math.Random? random,
    DateTime Function()? clock,
    this.minInterval = const Duration(milliseconds: 2400),
    this.maxInterval = const Duration(milliseconds: 4800),
  }) : _random = random ?? math.Random(),
       _clock = clock ?? DateTime.now;

  final math.Random _random;
  final DateTime Function() _clock;
  final Duration minInterval;
  final Duration maxInterval;
  int _sequence = 4100;

  static const List<_Platform> _visualPlatforms = <_Platform>[
    (name: 'Midjourney', version: 'v6.1'),
    (name: 'Stable Diffusion', version: 'XL'),
    (name: 'DALL·E', version: '3'),
    (name: 'Adobe Firefly', version: '3'),
    (name: 'Leonardo AI', version: 'Phoenix'),
    (name: 'Runway', version: 'Gen-3'),
  ];

  static const List<_Platform> _audioPlatforms = <_Platform>[
    (name: 'Suno', version: 'v4'),
    (name: 'Udio', version: 'v1.5'),
    (name: 'Stable Audio', version: '2.0'),
    (name: 'MusicGen', version: 'Large'),
  ];

  static const List<_Asset> _assets = <_Asset>[
    (
      name: "Qarabağ 'Xətai' naxışı",
      origin: 'Qarabağ xalçaçılıq məktəbi',
      category: HeritageCategory.carpet,
    ),
    (
      name: "Şirvan 'Buta' naxışı",
      origin: 'Şirvan xalçaçılıq məktəbi',
      category: HeritageCategory.carpet,
    ),
    (
      name: "Qazax 'Şıxlı' gölü",
      origin: 'Qazax xalçaçılıq məktəbi',
      category: HeritageCategory.carpet,
    ),
    (
      name: "Quba 'Qımıl' kompozisiyası",
      origin: 'Quba xalçaçılıq məktəbi',
      category: HeritageCategory.carpet,
    ),
    (
      name: "Təbriz 'Şah Abbası' medalyonu",
      origin: 'Təbriz xalçaçılıq məktəbi',
      category: HeritageCategory.carpet,
    ),
    (
      name: "Gəncə 'Fəxrəli' naxışı",
      origin: 'Gəncə xalçaçılıq məktəbi',
      category: HeritageCategory.carpet,
    ),
    (
      name: "'Rast' dəstgahı",
      origin: 'Azərbaycan muğamı · UNESCO',
      category: HeritageCategory.mugham,
    ),
    (
      name: "'Segah' dəstgahı",
      origin: 'Azərbaycan muğamı · UNESCO',
      category: HeritageCategory.mugham,
    ),
    (
      name: "'Bayatı-Şiraz' muğamı",
      origin: 'Azərbaycan muğamı · UNESCO',
      category: HeritageCategory.mugham,
    ),
    (
      name: 'Tar tembr imzası',
      origin: 'Tar sənətkarlığı · UNESCO',
      category: HeritageCategory.instrument,
    ),
    (
      name: 'Kamança ifa üslubu',
      origin: 'Milli çalğı alətləri',
      category: HeritageCategory.instrument,
    ),
    (
      name: "Balaban 'Dilqəmi' havası",
      origin: 'Aşıq sənəti · UNESCO',
      category: HeritageCategory.instrument,
    ),
    (
      name: 'Şəbəkə həndəsi motivi',
      origin: 'Şəki Xan Sarayı',
      category: HeritageCategory.ornament,
    ),
    (
      name: 'İslimi ornamenti',
      origin: 'Təbriz miniatür məktəbi',
      category: HeritageCategory.ornament,
    ),
  ];

  @override
  Future<DashboardSnapshot> fetchSnapshot() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final DateTime now = _clock();
    return DashboardSnapshot(
      metrics: const DashboardMetrics(
        protectedDnaCount: 1240,
        activeViolations: 89,
        licensingRevenueUsd: 12400,
        dnaGrowth: 0.082,
        violationsGrowth: 0.14,
        revenueGrowth: 0.236,
        dnaTrend: <double>[
          880,
          910,
          948,
          972,
          1004,
          1046,
          1080,
          1112,
          1150,
          1188,
          1214,
          1240,
        ],
        violationsTrend: <double>[
          41,
          47,
          44,
          56,
          61,
          58,
          66,
          72,
          70,
          79,
          84,
          89,
        ],
        revenueTrend: <double>[
          3100,
          3900,
          4600,
          5200,
          6100,
          6900,
          7800,
          8600,
          9500,
          10600,
          11500,
          12400,
        ],
      ),
      recentIncidents: List<Incident>.generate(
        6,
        (int i) => _nextIncident(
          detectedAt: now.subtract(Duration(seconds: 9 + i * 23)),
        ),
      ),
      platformExposure: const <PlatformExposure>[
        PlatformExposure(platform: 'Midjourney', incidents: 31),
        PlatformExposure(platform: 'Suno', incidents: 22),
        PlatformExposure(platform: 'Stable Diffusion', incidents: 17),
        PlatformExposure(platform: 'DALL·E', incidents: 9),
        PlatformExposure(platform: 'Udio', incidents: 6),
        PlatformExposure(platform: 'Runway', incidents: 4),
      ],
      coverage: const <HeritageCoverage>[
        HeritageCoverage(category: HeritageCategory.carpet, count: 642),
        HeritageCoverage(category: HeritageCategory.mugham, count: 318),
        HeritageCoverage(category: HeritageCategory.instrument, count: 184),
        HeritageCoverage(category: HeritageCategory.ornament, count: 96),
      ],
    );
  }

  @override
  Stream<Incident> watchIncidents() async* {
    final int spread = maxInterval.inMilliseconds - minInterval.inMilliseconds;
    while (true) {
      await Future<void>.delayed(
        minInterval + Duration(milliseconds: _random.nextInt(spread + 1)),
      );
      yield _nextIncident(detectedAt: _clock());
    }
  }

  Incident _nextIncident({required DateTime detectedAt}) {
    final _Asset asset = _assets[_random.nextInt(_assets.length)];
    final bool isAudio =
        asset.category == HeritageCategory.mugham ||
        asset.category == HeritageCategory.instrument;
    final List<_Platform> platforms = isAudio
        ? _audioPlatforms
        : _visualPlatforms;
    final _Platform platform = platforms[_random.nextInt(platforms.length)];

    final int roll = _random.nextInt(100);
    final IncidentStatus status = switch (roll) {
      < 58 => IncidentStatus.unauthorized,
      < 78 => IncidentStatus.underReview,
      < 88 => IncidentStatus.takedownSent,
      _ => IncidentStatus.licensed,
    };

    return Incident(
      id: 'INC-${_sequence++}',
      platform: platform.name,
      modelVersion: platform.version,
      assetName: asset.name,
      origin: asset.origin,
      category: asset.category,
      similarity: 0.82 + _random.nextDouble() * 0.17,
      status: status,
      detectedAt: detectedAt,
      licenseFeeUsd: status == IncidentStatus.licensed
          ? (120 + _random.nextInt(18) * 20).toDouble()
          : null,
    );
  }
}
