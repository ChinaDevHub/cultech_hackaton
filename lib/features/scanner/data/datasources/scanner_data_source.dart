import '../../domain/entities/copyright_claim.dart';
import '../../domain/entities/scan_media.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/scan_update.dart';

/// AI DNA analysis backend: either the CultGuard API or the offline demo.
abstract interface class ScannerDataSource {
  Stream<ScanUpdate> analyze(ScanMedia media);

  Future<CopyrightClaim> fileClaim(ScanResult result);
}
