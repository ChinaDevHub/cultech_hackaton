import 'dart:math' as math;

import '../../domain/entities/api_key.dart';
import '../../domain/entities/cultural_dataset.dart';
import '../../domain/entities/license_order.dart';
import '../../domain/entities/marketplace_catalog.dart';
import '../../domain/entities/pricing_plan.dart';
import 'marketplace_data_source.dart';

/// Offline marketplace with a curated catalog.
///
/// Demo keys are random 128-bit hex strings from [math.Random.secure]; in
/// API mode keys are minted by the backend and never generated on device.
final class MarketplaceDemoDataSource implements MarketplaceDataSource {
  MarketplaceDemoDataSource({math.Random? random, DateTime Function()? clock})
    : _random = random ?? math.Random.secure(),
      _clock = clock ?? DateTime.now;

  final math.Random _random;
  final DateTime Function() _clock;

  static const List<CulturalDataset> _datasets = <CulturalDataset>[
    CulturalDataset(
      id: 'ds-carpet-vectors',
      title: 'Azərbaycan Xalçaları — Vektor Dataseti',
      description:
          'Qarabağ, Şirvan, Qazax, Quba, Gəncə və Təbriz məktəblərindən 12 400 '
          'xalça naxışının yüksək dəqiqlikli skanı, SVG vektorları və motiv '
          'annotasiyaları.',
      modality: DatasetModality.visual,
      itemCount: 12400,
      itemUnit: 'nümunə',
      sizeLabel: '86 GB',
      formats: <String>['PNG 8K', 'SVG', 'JSON-LD'],
      useCases: <String>['AI təlimi', 'GameDev', 'Moda'],
      priceUsd: 2400,
      licenseType: 'CG-Commercial v1',
      rating: 4.9,
    ),
    CulturalDataset(
      id: 'ds-mugham-corpus',
      title: 'Muğam Dəstgahları — Audio Korpus',
      description:
          '840 saatlıq lisenziyalı muğam ifası: Rast, Segah, Şur, Çahargah və '
          'digər dəstgahlar üzrə şöbə-şöbə seqmentasiya və notasiya.',
      modality: DatasetModality.audio,
      itemCount: 840,
      itemUnit: 'saat',
      sizeLabel: '212 GB',
      formats: <String>['WAV 48kHz', 'MIDI', 'MusicXML'],
      useCases: <String>['Musiqi AI', 'Film', 'Təhsil'],
      priceUsd: 3600,
      licenseType: 'CG-Audio Pro',
      rating: 4.8,
    ),
    CulturalDataset(
      id: 'ds-instrument-timbre',
      title: 'Milli Alətlər — Tembr Bankı',
      description:
          'Tar, kamança, balaban, saz, qaval və nağara üçün 18 000 '
          'çoxsəviyyəli sempl; hər not dinamik və artikulyasiya üzrə.',
      modality: DatasetModality.audio,
      itemCount: 18000,
      itemUnit: 'sempl',
      sizeLabel: '64 GB',
      formats: <String>['WAV 96kHz', 'SFZ', 'Kontakt'],
      useCases: <String>['GameDev', 'Səs dizaynı'],
      priceUsd: 1800,
      licenseType: 'CG-Commercial v1',
      rating: 4.9,
    ),
    CulturalDataset(
      id: 'ds-ornament-3d',
      title: 'Memarlıq Ornamentləri — 3D Teksturlar',
      description:
          'Şəki Xan Sarayının şəbəkə pəncərələri, İçərişəhər daş oymaları və '
          'Möminə Xatın türbəsi motivlərindən PBR 3D teksturlar.',
      modality: DatasetModality.model3d,
      itemCount: 3200,
      itemUnit: 'tekstur',
      sizeLabel: '140 GB',
      formats: <String>['PBR 4K', 'glTF', 'USDZ'],
      useCases: <String>['GameDev', 'AR/VR', 'Memarlıq'],
      priceUsd: 2900,
      licenseType: 'CG-3D Commercial',
      rating: 4.7,
    ),
    CulturalDataset(
      id: 'ds-miniature-palettes',
      title: 'Təbriz Miniatürləri — Rəng və Kompozisiya',
      description:
          'Miniatür rəngkarlığından rəng palitraları, kompozisiya sxemləri və '
          'personaj siluetləri — stil-transfer modelləri üçün etik mənbə.',
      modality: DatasetModality.visual,
      itemCount: 5600,
      itemUnit: 'nümunə',
      sizeLabel: '38 GB',
      formats: <String>['TIFF', 'ASE', 'COCO'],
      useCases: <String>['AI təlimi', 'İllüstrasiya'],
      priceUsd: 1500,
      licenseType: 'CG-Commercial v1',
      rating: 4.6,
    ),
    CulturalDataset(
      id: 'ds-ashiq-archive',
      title: 'Aşıq Sənəti — Multimodal Arxiv',
      description:
          'Aşıq havaları, dastan mətnləri və ifa videoları: saz ifası ilə '
          'sinxronlaşdırılmış transkripsiyalar və metadata.',
      modality: DatasetModality.multimodal,
      itemCount: 420,
      itemUnit: 'saat',
      sizeLabel: '310 GB',
      formats: <String>['MP4', 'WAV', 'TEI-XML'],
      useCases: <String>['LLM', 'Musiqi AI', 'Arxiv'],
      priceUsd: 4200,
      licenseType: 'CG-Research+',
      rating: 4.8,
    ),
  ];

  static const List<PricingPlan> _plans = <PricingPlan>[
    PricingPlan(
      tier: PlanTier.starter,
      name: 'Starter',
      price: r'$49',
      period: '/ay',
      tagline: 'İndie studiyalar və tədqiqatçılar üçün',
      apiQuota: '10 000 API sorğusu / ay',
      features: <String>[
        '1 dataset lisenziyası',
        'AI DNT yoxlama API-si',
        'Standart kommersiya lisenziyası',
        'E-poçt dəstəyi',
      ],
    ),
    PricingPlan(
      tier: PlanTier.enterprise,
      name: 'Enterprise',
      price: r'$1,490',
      period: '/ay',
      tagline: 'GameDev və AI şirkətləri üçün',
      apiQuota: '2 mln API sorğusu / ay',
      features: <String>[
        'Bütün datasetlərə giriş',
        'Real-vaxt pozuntu monitorinqi',
        'Model təlimi üçün geniş lisenziya',
        '99.95% SLA · prioritet dəstək',
      ],
      highlighted: true,
    ),
    PricingPlan(
      tier: PlanTier.sovereign,
      name: 'Cultural Sovereign',
      price: 'Fərdi',
      period: '',
      tagline: 'Dövlət qurumları və milli platformalar üçün',
      apiQuota: 'Limitsiz · on-premise',
      features: <String>[
        'Milli AI DNT reyestri',
        'Hüquqi iddia avtomatlaşdırması',
        'Suveren bulud / on-premise',
        'Gəlir bölgüsü idarəetməsi',
      ],
    ),
  ];

  @override
  Future<MarketplaceCatalog> fetchCatalog() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const MarketplaceCatalog(datasets: _datasets, plans: _plans);
  }

  @override
  Future<ApiKey> createApiKey(ApiEnvironment environment) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final String secret = List<String>.generate(
      32,
      (_) => _random.nextInt(16).toRadixString(16),
    ).join();
    return ApiKey(
      value: '${environment.prefix}$secret',
      environment: environment,
      createdAt: _clock(),
      scopes: const <String>['datasets:read', 'dna:match', 'incidents:read'],
    );
  }

  @override
  Future<LicenseOrder> createLicenseOrder(CulturalDataset dataset) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final DateTime now = _clock();
    return LicenseOrder(
      id: 'CG-ORD-${now.year}-${1000 + _random.nextInt(8999)}',
      datasetId: dataset.id,
      datasetTitle: dataset.title,
      createdAt: now,
    );
  }
}
