/// Where the EsperFlow backend lives, and how we authenticate with it.
///
/// Override at build time so no URL is hard-coded into a release build:
///
/// ```
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
///             --dart-define=API_KEY=your-secret
/// ```
///
/// The default targets the Android emulator, where `10.0.2.2` is the host
/// machine's `localhost`. On a physical phone use your PC's LAN IP
/// (`ipconfig`), and make sure the backend runs with `--host 0.0.0.0`.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.18.251:8000',
  );

  /// Must match `API_KEY` in the backend's `.env` when that is set.
  static const String apiKey = String.fromEnvironment('API_KEY');

  /// How long to wait for the broadcast to finish before giving up.
  ///
  /// Sized for a cold start: a free-tier host (Render, Fly, …) sleeps after
  /// ~15 min idle and needs the better part of a minute to wake, and the very
  /// first request of the day pays that. A local or always-on backend answers
  /// in well under a second, so this ceiling is only ever hit when something is
  /// genuinely wrong. Lower it with
  /// `--dart-define=API_TIMEOUT_SECONDS=20` once the backend is always on.
  static const Duration timeout = Duration(
    seconds: int.fromEnvironment('API_TIMEOUT_SECONDS', defaultValue: 60),
  );

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (apiKey.isNotEmpty) 'x-api-key': apiKey,
  };

  static Uri endpoint(String path, [Map<String, dynamic>? query]) => Uri.parse(
    '$baseUrl$path',
  ).replace(queryParameters: query?.map((k, v) => MapEntry(k, '$v')));
}
