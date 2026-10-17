/// Exceptions thrown by data sources. Repositories translate them into
/// [Failure]s so they never leak into the domain or presentation layers.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});

  final int? statusCode;
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {this.isLikelyCors = false});

  /// On the web a blocked CORS preflight is indistinguishable from a network
  /// error; this flag lets the UI hint at the backend configuration.
  final bool isLikelyCors;
}

final class MediaPickException extends AppException {
  const MediaPickException(super.message);
}

final class MediaValidationException extends AppException {
  const MediaValidationException(super.message);
}
