import '../../../../core/utils/result.dart';
import '../entities/copyright_claim.dart';
import '../entities/scan_media.dart';
import '../entities/scan_result.dart';
import '../entities/scan_update.dart';
import '../entities/scanner_capabilities.dart';

abstract interface class ScannerRepository {
  ScannerCapabilities get capabilities;

  List<ScanMedia> get demoSamples;

  /// Returns `Ok(null)` when the user cancels the picker.
  Future<Result<ScanMedia?>> pickMedia(MediaOrigin origin);

  /// Runs the AI DNA pipeline. Errors are emitted as [Failure]s.
  Stream<ScanUpdate> scan(ScanMedia media);

  Future<Result<CopyrightClaim>> fileCopyrightClaim(ScanResult result);
}
