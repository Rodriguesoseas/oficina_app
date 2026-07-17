import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../providers/providers.dart';
import '../theme/app_spacing.dart';

class ConfiguracoesScreen extends ConsumerWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.mecanico;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (user != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Usuário', style: theme.textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.md),
                    _InfoRow(label: 'Nome', value: user.nome),
                    _InfoRow(label: 'Email', value: user.email),
                    _InfoRow(
                      label: 'Tipo',
                      value: user.isAdmin ? 'Administrador' : 'Mecânico',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    darkMode ? Icons.dark_mode : Icons.light_mode,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Modo escuro'),
                  subtitle: Text(
                    darkMode ? 'Tema escuro ativado' : 'Tema claro ativado',
                    style: theme.textTheme.bodySmall,
                  ),
                  value: darkMode,
                  onChanged: (v) => ref.read(darkModeProvider.notifier).state = v,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informações do Sistema', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.md),
                  _InfoRow(label: 'Versão', value: '1.1.0'),
                  _InfoRow(label: 'API', value: ApiConfig.baseUrl),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sair'),
                    content: const Text('Deseja realmente sair?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Sair'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  ref.read(authProvider.notifier).logout();
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sair da conta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
          ),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
