import '../../../../core/error/failure_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/copyright_claim.dart';
import '../../domain/entities/scan_media.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/scan_update.dart';
import '../../domain/entities/scanner_capabilities.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasources/demo_samples.dart';
import '../datasources/media_picker_data_source.dart';
import '../datasources/scanner_data_source.dart';

final class ScannerRepositoryImpl implements ScannerRepository {
  const ScannerRepositoryImpl({
    required this._mediaPicker,
    required this._scanner,
    required this._demoScanner,
  });

  final MediaPickerDataSource _mediaPicker;
  final ScannerDataSource _scanner;

  /// Built-in samples are always resolved offline, even in API mode.
  final ScannerDataSource _demoScanner;

  @override
  ScannerCapabilities get capabilities => _mediaPicker.capabilities;

  @override
  List<ScanMedia> get demoSamples => DemoSamples.all;

  @override
  Future<Result<ScanMedia?>> pickMedia(MediaOrigin origin) async {
    try {
      return Result<ScanMedia?>.ok(await _mediaPicker.pick(origin));
    } on Object catch (error) {
      return Result<ScanMedia?>.err(mapExceptionToFailure(error));
    }
  }

  @override
  Stream<ScanUpdate> scan(ScanMedia media) {
    final ScannerDataSource source = media.isSample ? _demoScanner : _scanner;
    return source
        .analyze(media)
        .handleError((Object error) => throw mapExceptionToFailure(error));
  }

  @override
  Future<Result<CopyrightClaim>> fileCopyrightClaim(ScanResult result) async {
    final ScannerDataSource source = result.media.isSample
        ? _demoScanner
        : _scanner;
    try {
      return Result<CopyrightClaim>.ok(await source.fileClaim(result));
    } on Object catch (error) {
      return Result<CopyrightClaim>.err(mapExceptionToFailure(error));
    }
  }
}
