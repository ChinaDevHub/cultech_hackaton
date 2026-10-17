import 'package:equatable/equatable.dart';

/// Domain-level failure returned by repositories instead of throwing.
///
/// Every failure carries a user-presentable [message] (Azerbaijani) so the
/// presentation layer never has to translate infrastructure errors.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Connectivity problems, timeouts or browser-level (CORS) rejections.
final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Şəbəkə bağlantısı alınmadı. İnterneti yoxlayın.',
  ]);
}

/// The backend answered with a non-success status code.
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => <Object?>[message, statusCode];
}

/// A platform capability (camera, file system, clipboard) is unavailable
/// or the user denied access to it.
final class PlatformFailure extends Failure {
  const PlatformFailure(super.message);
}

/// The input did not pass validation (e.g. unsupported or too large file).
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Gözlənilməz xəta baş verdi. Yenidən cəhd edin.',
  ]);
}
