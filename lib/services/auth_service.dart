import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/api/api_client.dart';
import '../models/mecanico.dart';

class AuthService {
  AuthService(this._client);

  final ApiClient _client;
  static const _tokenKey = 'jwt_token';
  static final _storage = FlutterSecureStorage();

  Future<String?> getSavedToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<bool> adminExists() async {
    final data = await _client.get<Map<String, dynamic>>(
      '/auth/status',
      parser: (d) => d as Map<String, dynamic>,
    );
    return data['admin_exists'] == true;
  }

  Future<({String token, Mecanico mecanico})> setupAdmin({
    required String nome,
    required String email,
    required String password,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/auth/setup',
      data: {'nome': nome, 'email': email, 'password': password},
      parser: (d) => d as Map<String, dynamic>,
    );
    return (
      token: data['token'] as String,
      mecanico: Mecanico.fromJson(data['mecanico'] as Map<String, dynamic>),
    );
  }

  Future<({String token, Mecanico mecanico})> login({
    required String email,
    required String password,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
      parser: (d) => d as Map<String, dynamic>,
    );
    return (
      token: data['token'] as String,
      mecanico: Mecanico.fromJson(data['mecanico'] as Map<String, dynamic>),
    );
  }

  Future<Mecanico> getMe() async {
    final data = await _client.get<Map<String, dynamic>>(
      '/auth/me',
      parser: (d) => d as Map<String, dynamic>,
    );
    return Mecanico.fromJson(data['mecanico'] as Map<String, dynamic>);
  }

  Future<List<Mecanico>> listarMecanicos() async {
    return _client.get<List<Mecanico>>(
      '/admin/mecanicos',
      parser: (data) => (data as List)
          .map((e) => Mecanico.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Mecanico> criarMecanico({
    required String nome,
    required String email,
    required String password,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/admin/mecanicos',
      data: {'nome': nome, 'email': email, 'password': password},
      parser: (d) => d as Map<String, dynamic>,
    );
    return Mecanico.fromJson(data);
  }
}
