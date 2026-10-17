import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/copyright_claim.dart';
import '../entities/scan_media.dart';
import '../entities/scan_result.dart';
import '../entities/scan_update.dart';
import '../entities/scanner_capabilities.dart';
import '../repositories/scanner_repository.dart';

class GetScannerCapabilities {
  const GetScannerCapabilities(this._repository);

  final ScannerRepository _repository;

  ScannerCapabilities call() => _repository.capabilities;
}

class GetDemoSamples {
  const GetDemoSamples(this._repository);

  final ScannerRepository _repository;

  List<ScanMedia> call() => _repository.demoSamples;
}

class PickScanMedia implements UseCase<ScanMedia?, MediaOrigin> {
  const PickScanMedia(this._repository);

  final ScannerRepository _repository;

  @override
  Future<Result<ScanMedia?>> call(MediaOrigin params) =>
      _repository.pickMedia(params);
}

class RunAiDnaScan implements StreamUseCase<ScanUpdate, ScanMedia> {
  const RunAiDnaScan(this._repository);

  final ScannerRepository _repository;

  @override
  Stream<ScanUpdate> call(ScanMedia params) => _repository.scan(params);
}

class FileCopyrightClaim implements UseCase<CopyrightClaim, ScanResult> {
  const FileCopyrightClaim(this._repository);

  final ScannerRepository _repository;

  @override
  Future<Result<CopyrightClaim>> call(ScanResult params) {
    // Business rule: only confirmed infringements can be claimed.
    if (!params.isInfringement) {
      return Future<Result<CopyrightClaim>>.value(
        const Result<CopyrightClaim>.err(
          ValidationFailure(
            'Lisenziyalı istifadə üçün iddia qaldırıla bilməz.',
          ),
        ),
      );
    }
    return _repository.fileCopyrightClaim(params);
  }
}
