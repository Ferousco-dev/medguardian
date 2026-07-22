/// Build-time configuration.
///
/// The backend URL is injected with `--dart-define` so no environment file has
/// to be committed and the same binary can point at local, staging or
/// production without a code change.
///
/// ```bash
/// flutter run --dart-define=API_BASE_URL=https://api.example.com
/// ```
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// When true the app serves demo data from local fixtures instead of calling
  /// the network. This is on automatically whenever no backend URL was
  /// supplied, so the app is always runnable.
  static bool get useMockData =>
      const bool.fromEnvironment('USE_MOCK_DATA', defaultValue: false) ||
      apiBaseUrl.isEmpty;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  const AppConfig._();
}
