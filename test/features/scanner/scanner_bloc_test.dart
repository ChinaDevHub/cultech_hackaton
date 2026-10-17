import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cultech_hackaton/core/error/failures.dart';
import 'package:cultech_hackaton/core/utils/result.dart';
import 'package:cultech_hackaton/features/scanner/data/datasources/demo_samples.dart';
import 'package:cultech_hackaton/features/scanner/data/datasources/heritage_catalog.dart';
import 'package:cultech_hackaton/features/scanner/domain/entities/ai_dna_fingerprint.dart';
import 'package:cultech_hackaton/features/scanner/domain/entities/copyright_claim.dart';
import 'package:cultech_hackaton/features/scanner/domain/entities/scan_media.dart';
import 'package:cultech_hackaton/features/scanner/domain/entities/scan_result.dart';
import 'package:cultech_hackaton/features/scanner/domain/entities/scan_update.dart';
import 'package:cultech_hackaton/features/scanner/domain/entities/scanner_capabilities.dart';
import 'package:cultech_hackaton/features/scanner/domain/usecases/scanner_usecases.dart';
import 'package:cultech_hackaton/features/scanner/presentation/bloc/scanner_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCapabilities extends Mock implements GetScannerCapabilities {}

class _MockSamples extends Mock implements GetDemoSamples {}

class _MockPick extends Mock implements PickScanMedia {}

class _MockScan extends Mock implements RunAiDnaScan {}

class _MockClaim extends Mock implements FileCopyrightClaim {}

const ScannerCapabilities _caps = ScannerCapabilities(
  cameraAvailable: false,
  maxFileSizeBytes: 1024,
  imageExtensions: <String>['png'],
  audioExtensions: <String>['mp3'],
);

final ScanMedia _sample = DemoSamples.all.first;

final ScanResult _result = ScanResult(
  id: 'SCN-1',
  media: _sample,
  status: LicenseStatus.unauthorized,
  origin: HeritageCatalog.shirvanBoteh,
  similarity: 0.968,
  fingerprint: const AiDnaFingerprint(
    hash: '7f3a9c11e21b0000000000000000000000000000000000000000000000e21b',
    vector: <double>[0.1, 0.5, 0.9],
  ),
  matchedSource: 'Midjourney v6.1',
  matchedOutputs: 3,
  scannedAt: DateTime(2026),
  licenseQuoteUsd: 2400,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_sample);
    registerFallbackValue(_result);
    registerFallbackValue(MediaOrigin.gallery);
  });

  late _MockCapabilities capabilities;
  late _MockSamples samples;
  late _MockPick pick;
  late _MockScan scan;
  late _MockClaim claim;

  setUp(() {
    capabilities = _MockCapabilities();
    samples = _MockSamples();
    pick = _MockPick();
    scan = _MockScan();
    claim = _MockClaim();
    when(() => capabilities()).thenReturn(_caps);
    when(() => samples()).thenReturn(DemoSamples.all);
  });

  ScannerBloc build() => ScannerBloc(
    getCapabilities: capabilities,
    getDemoSamples: samples,
    pickMedia: pick,
    runScan: scan,
    fileClaim: claim,
  );

  blocTest<ScannerBloc, ScannerState>(
    'runs a full scan from sample selection to verdict',
    setUp: () => when(() => scan(any())).thenAnswer(
      (_) => Stream<ScanUpdate>.fromIterable(<ScanUpdate>[
        const ScanProgressed(
          stage: ScanStage.vectorize,
          progress: 0.3,
          log: 'vector',
        ),
        const ScanProgressed(
          stage: ScanStage.datasetLookup,
          progress: 0.8,
          log: 'lookup',
        ),
        ScanCompleted(_result),
      ]),
    ),
    build: build,
    act: (ScannerBloc bloc) => bloc
      ..add(ScannerSampleSelected(_sample))
      ..add(const ScannerScanRequested()),
    expect: () => <Matcher>[
      isA<ScannerState>().having(
        (ScannerState s) => s.status,
        'status',
        ScannerStatus.ready,
      ),
      isA<ScannerState>()
          .having(
            (ScannerState s) => s.status,
            'status',
            ScannerStatus.scanning,
          )
          .having((ScannerState s) => s.stage, 'stage', ScanStage.ingest),
      isA<ScannerState>().having((ScannerState s) => s.logs.length, 'logs', 1),
      isA<ScannerState>()
          .having((ScannerState s) => s.stage, 'stage', ScanStage.datasetLookup)
          .having((ScannerState s) => s.progress, 'progress', 0.8),
      isA<ScannerState>()
          .having(
            (ScannerState s) => s.status,
            'status',
            ScannerStatus.completed,
          )
          .having((ScannerState s) => s.result, 'result', _result),
    ],
  );

  blocTest<ScannerBloc, ScannerState>(
    'picker failures become error notices without changing status',
    setUp: () => when(() => pick(any())).thenAnswer(
      (_) async => const Result<ScanMedia?>.err(
        PlatformFailure('Kameraya giriş icazəsi verilməyib.'),
      ),
    ),
    build: build,
    act: (ScannerBloc bloc) =>
        bloc.add(const ScannerMediaRequested(MediaOrigin.camera)),
    expect: () => <Matcher>[
      isA<ScannerState>()
          .having((ScannerState s) => s.status, 'status', ScannerStatus.idle)
          .having((ScannerState s) => s.notice?.isError, 'isError', true),
    ],
  );

  blocTest<ScannerBloc, ScannerState>(
    'cancelled picker is a no-op',
    setUp: () => when(
      () => pick(any()),
    ).thenAnswer((_) async => const Result<ScanMedia?>.ok(null)),
    build: build,
    act: (ScannerBloc bloc) =>
        bloc.add(const ScannerMediaRequested(MediaOrigin.gallery)),
    expect: () => <ScannerState>[],
  );

  blocTest<ScannerBloc, ScannerState>(
    'reset cancels an in-flight scan',
    setUp: () {
      final StreamController<ScanUpdate> never = StreamController<ScanUpdate>();
      addTearDown(() => unawaited(never.close()));
      when(() => scan(any())).thenAnswer((_) => never.stream);
    },
    build: build,
    act: (ScannerBloc bloc) async {
      bloc
        ..add(ScannerSampleSelected(_sample))
        ..add(const ScannerScanRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ScannerResetRequested());
    },
    verify: (ScannerBloc bloc) {
      expect(bloc.state.status, ScannerStatus.idle);
      expect(bloc.state.media, isNull);
    },
  );

  blocTest<ScannerBloc, ScannerState>(
    'files a copyright claim for an infringement',
    setUp: () => when(() => claim(any())).thenAnswer(
      (_) async => Result<CopyrightClaim>.ok(
        CopyrightClaim(
          id: 'CG-CLM-2026-12345',
          scanId: 'SCN-1',
          respondent: 'Midjourney v6.1',
          filedAt: DateTime(2026),
          responseDeadline: DateTime(2026, 1, 4),
        ),
      ),
    ),
    build: build,
    seed: () => ScannerState(
      capabilities: _caps,
      samples: DemoSamples.all,
      status: ScannerStatus.completed,
      media: _sample,
      result: _result,
    ),
    act: (ScannerBloc bloc) => bloc.add(const ScannerClaimRequested()),
    expect: () => <Matcher>[
      isA<ScannerState>().having(
        (ScannerState s) => s.claimStatus,
        'claim',
        ClaimStatus.submitting,
      ),
      isA<ScannerState>()
          .having((ScannerState s) => s.claimStatus, 'claim', ClaimStatus.filed)
          .having((ScannerState s) => s.claim?.id, 'id', 'CG-CLM-2026-12345')
          .having((ScannerState s) => s.notice?.isError, 'isError', false),
    ],
  );
}
