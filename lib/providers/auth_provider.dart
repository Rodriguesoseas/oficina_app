import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../models/mecanico.dart';
import '../services/auth_service.dart';

enum AuthStatus { loading, unauthenticated, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.loading,
    this.mecanico,
    this.token,
    this.adminExists = false,
  });

  final AuthStatus status;
  final Mecanico? mecanico;
  final String? token;
  final bool adminExists;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isAdmin => mecanico?.isAdmin ?? false;

  AuthState copyWith({
    AuthStatus? status,
    Mecanico? mecanico,
    String? token,
    bool? adminExists,
  }) {
    return AuthState(
      status: status ?? this.status,
      mecanico: mecanico ?? this.mecanico,
      token: token ?? this.token,
      adminExists: adminExists ?? this.adminExists,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService, this._apiClient)
      : super(const AuthState()) {
    _init();
  }

  final AuthService _authService;
  final ApiClient _apiClient;

  Future<void> _init() async {
    final savedToken = await _authService.getSavedToken();
    if (savedToken != null) {
      _apiClient.setToken(savedToken);
      try {
        final mecanico = await _authService.getMe();
        state = AuthState(
          status: AuthStatus.authenticated,
          mecanico: mecanico,
          token: savedToken,
        );
        return;
      } catch (_) {
        await _authService.clearToken();
        _apiClient.setToken(null);
      }
    }

    try {
      final exists = await _authService.adminExists();
      state = AuthState(
        status: AuthStatus.unauthenticated,
        adminExists: exists,
      );
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        adminExists: false,
      );
    }
  }

  Future<void> setupAdmin({
    required String nome,
    required String email,
    required String password,
  }) async {
    final result = await _authService.setupAdmin(
      nome: nome,
      email: email,
      password: password,
    );
    _apiClient.setToken(result.token);
    await _authService.saveToken(result.token);
    state = AuthState(
      status: AuthStatus.authenticated,
      mecanico: result.mecanico,
      token: result.token,
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final result = await _authService.login(
      email: email,
      password: password,
    );
    _apiClient.setToken(result.token);
    await _authService.saveToken(result.token);
    state = AuthState(
      status: AuthStatus.authenticated,
      mecanico: result.mecanico,
      token: result.token,
    );
  }

  Future<void> logout() async {
    await _authService.clearToken();
    _apiClient.setToken(null);
    state = const AuthState(
      status: AuthStatus.unauthenticated,
    );
  }

  Future<void> refreshAdminExists() async {
    try {
      final exists = await _authService.adminExists();
      state = state.copyWith(adminExists: exists);
    } catch (_) {}
  }
}
