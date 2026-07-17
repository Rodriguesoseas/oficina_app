import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _token = String.fromEnvironment('API_TOKEN');
  static const String _url = String.fromEnvironment('API_BASE_URL');

  static String get apiToken =>
      _token.isNotEmpty ? _token : 'dev-token';

  static String get baseUrl {
    if (_url.isNotEmpty) return _url;

    if (kDebugMode) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:3000/api/v1';
      }
      return 'http://localhost:3000/api/v1';
    }

    return 'https://oficina-api-kmdf.onrender.com/api/v1';
  }
}