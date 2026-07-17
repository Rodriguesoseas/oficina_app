import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_provider.dart';
import 'providers/providers.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/setup_admin_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: A2MMotosApp()));
}

class A2MMotosApp extends ConsumerWidget {
  const A2MMotosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escuro = ref.watch(darkModeProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'A2M Motos',
      debugShowCheckedModeBanner: false,
      themeMode: escuro ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('pt', 'BR'),
      home: _buildHome(authState),
    );
  }

  Widget _buildHome(AuthState authState) {
    switch (authState.status) {
      case AuthStatus.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.unauthenticated:
        if (authState.adminExists) {
          return const LoginScreen();
        }
        return const SetupAdminScreen();
      case AuthStatus.authenticated:
        return const MainShell();
    }
  }
}
