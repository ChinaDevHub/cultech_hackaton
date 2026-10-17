import '../../domain/entities/scan_media.dart';
import '../../domain/entities/scan_result.dart';
import 'heritage_catalog.dart';

/// Scripted outcome for a built-in demo sample.
typedef DemoOutcome = ({
  HeritageOrigin origin,
  LicenseStatus status,
  double similarity,
  String source,
  int outputs,
  String? licensee,
});

/// Built-in samples so the scanner can be demoed without any files —
/// essential on a hackathon stage with an unfamiliar laptop.
abstract final class DemoSamples {
  static const String midjourneyCarpet = 'sample-mj-buta';
  static const String sunoMugham = 'sample-suno-rast';
  static const String licensedTexture = 'sample-licensed-qazax';

  static const List<ScanMedia> all = <ScanMedia>[
    ScanMedia(
      id: midjourneyCarpet,
      sampleId: midjourneyCarpet,
      name: 'midjourney_buta_pattern_v6.png',
      kind: MediaKind.image,
      sizeInBytes: 2516582,
    ),
    ScanMedia(
      id: sunoMugham,
      sampleId: sunoMugham,
      name: 'suno_oriental_lofi_v4.mp3',
      kind: MediaKind.audio,
      sizeInBytes: 4299161,
    ),
    ScanMedia(
      id: licensedTexture,
      sampleId: licensedTexture,
      name: 'gamedev_qazax_texture_4k.png',
      kind: MediaKind.image,
      sizeInBytes: 7130317,
    ),
  ];

  static DemoOutcome? outcomeFor(String? sampleId) {
    return switch (sampleId) {
      midjourneyCarpet => (
        origin: HeritageCatalog.shirvanBoteh,
        status: LicenseStatus.unauthorized,
        similarity: 0.968,
        source: 'Midjourney v6.1',
        outputs: 3,
        licensee: null,
      ),
      sunoMugham => (
        origin: HeritageCatalog.mughamRast,
        status: LicenseStatus.unauthorized,
        similarity: 0.934,
        source: 'Suno v4',
        outputs: 12,
        licensee: null,
      ),
      licensedTexture => (
        origin: HeritageCatalog.qazaxShixli,
        status: LicenseStatus.licensed,
        similarity: 0.912,
        source: 'Unreal Engine Marketplace',
        outputs: 1,
        licensee: 'Caspian Pixel Studio · CG-LIC-2026-0091',
      ),
      _ => null,
    };
  }
}
