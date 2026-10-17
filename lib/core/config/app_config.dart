/// Build-time configuration supplied through `--dart-define`.
///
/// ```bash
/// flutter run -d chrome --dart-define=CG_API_BASE_URL=https://api.cultguard.az
/// ```
///
/// When no base URL is provided the app runs against the in-process demo
/// backend, so the MVP is fully functional offline (e.g. on a hackathon stage).
final class AppConfig {
  const AppConfig({required this.apiBaseUrl, this.apiKey = ''});

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      apiBaseUrl: String.fromEnvironment('CG_API_BASE_URL'),
      // ignore: avoid_redundant_argument_values
      apiKey: String.fromEnvironment('CG_API_KEY'),
    );
  }

  final String apiBaseUrl;
  final String apiKey;

  bool get useDemoBackend => apiBaseUrl.isEmpty;

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
