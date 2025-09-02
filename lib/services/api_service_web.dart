import 'package:http/http.dart' as http;

/// Web implementation for HTTP client creation
/// Note: Web platform doesn't support SSL certificate bypass
http.Client createHttpClient(bool bypassSSL) {
  // Web always uses standard HTTP client
  // SSL certificate bypass is not possible on web
  return http.Client();
}