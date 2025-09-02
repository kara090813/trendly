import 'package:http/http.dart' as http;

/// Stub implementation for platform-specific HTTP client creation
/// This is used during compilation to provide a common interface
http.Client createHttpClient(bool bypassSSL) {
  throw UnsupportedError('Platform not supported');
}