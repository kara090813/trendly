import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// IO (mobile/desktop) implementation for HTTP client creation
http.Client createHttpClient(bool bypassSSL) {
  if (bypassSSL) {
    // SSL 인증서 검증을 우회하는 HttpClient 생성
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return IOClient(httpClient);
  } else {
    // 일반 HTTP 클라이언트 사용
    return http.Client();
  }
}