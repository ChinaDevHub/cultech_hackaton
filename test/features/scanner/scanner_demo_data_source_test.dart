import 'package:cultech_hackaton/features/scanner/data/datasources/demo_samples.dart';
import 'package:cultech_hackaton/features/scanner/data/datasources/scanner_demo_data_source.dart';
import 'package:cultech_hackaton/features/scanner/domain/entities/scan_media.dart';
import 'package:cultech_hackaton/features/scanner/domain/entities/scan_result.dart';
import 'package:cultech_hackaton/features/scanner/domain/entities/scan_update.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ScannerDemoDataSource source = ScannerDemoDataSource(
    stepDelay: Duration.zero,
  );

  Future<ScanResult> run(ScanMedia media) async {
    final List<ScanUpdate> updates = await source.analyze(media).toList();
    final List<double> progress = updates
        .whereType<ScanProgressed>()
        .map((ScanProgressed p) => p.progress)
        .toList();
    expect(progress, orderedEquals(<double>[...progress]..sort()));
    expect(updates.last, isA<ScanCompleted>());
    return (updates.last as ScanCompleted).result;
  }

  test('Midjourney sample resolves to the Şirvan buta infringement', () async {
    final ScanResult result = await run(DemoSamples.all[0]);
    expect(result.status, LicenseStatus.unauthorized);
    expect(result.similarity, closeTo(0.968, 1e-9));
    expect(result.origin.school, 'Şirvan Xalçaçılıq Məktəbi');
    expect(result.matchedSource, 'Midjourney v6.1');
  });

  test('licensed texture sample is verified', () async {
    final ScanResult result = await run(DemoSamples.all[2]);
    expect(result.status, LicenseStatus.licensed);
    expect(result.licenseHolder, isNotNull);
  });

  test('uploaded files get a deterministic verdict', () async {
    const ScanMedia media = ScanMedia(
      id: 'upload-1',
      name: 'pattern.png',
      kind: MediaKind.image,
      sizeInBytes: 10,
    );
    final ScanResult first = await run(media);
    final ScanResult second = await run(media);
    expect(first.status, second.status);
    expect(first.similarity, second.similarity);
    expect(first.similarity, inInclusiveRange(0.86, 0.99));
  });
}
