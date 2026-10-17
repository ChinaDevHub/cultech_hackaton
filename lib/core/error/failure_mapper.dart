import 'exceptions.dart';
import 'failures.dart';

/// Single place that turns data-layer exceptions into domain failures.
Failure mapExceptionToFailure(Object error) {
  return switch (error) {
    ServerException(:final String message, :final int? statusCode) =>
      ServerFailure(message, statusCode: statusCode),
    NetworkException(:final String message) => NetworkFailure(message),
    MediaPickException(:final String message) => PlatformFailure(message),
    MediaValidationException(:final String message) => ValidationFailure(
      message,
    ),
    _ => const UnexpectedFailure(),
  };
}
