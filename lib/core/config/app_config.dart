abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static bool get useMockData =>
      const bool.fromEnvironment('USE_MOCK_DATA', defaultValue: false) ||
      apiBaseUrl.isEmpty;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  const AppConfig._();
}
