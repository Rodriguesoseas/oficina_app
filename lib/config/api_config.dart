class ApiConfig {
  ApiConfig._();

  static const String _token = String.fromEnvironment('API_TOKEN');
  static const String _url = String.fromEnvironment('API_BASE_URL');

  static String get apiToken => _token;

  static String get baseUrl {
    if (_url.isNotEmpty) return _url;
    return 'https://oficina-api-kmdf.onrender.com/api/v1';
  }
}