import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cliente.dart';
import '../providers/providers.dart';
import '../utils/extensions.dart';
import '../widgets/cliente_tile.dart';
import 'cliente_detail_screen.dart';
import 'cliente_form_screen.dart';
import 'clientes_list_screen.dart';
import 'estoque_list_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientesAsync = ref.watch(clientesListProvider);
    final theme = Theme.of(context);
    final isDark = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oficina'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ClientesListScreen(),
                ),
              );
            },
            icon: const Icon(Icons.search),
            tooltip: 'Buscar clientes',
          ),
          IconButton(
            onPressed: () {
              ref.read(darkModeProvider.notifier).update((state) => !state);
            },
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Alternar tema',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(clientesListProvider);
          await ref.read(clientesListProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
          children: [
            _buildHeader(context, theme),
            const SizedBox(height: 20),
            _buildQuickActions(context, ref, theme),
            const SizedBox(height: 20),
            _buildClientesSection(context, ref, theme, clientesAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'O que deseja fazer hoje?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
      BuildContext context, WidgetRef ref, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.person_add,
            label: 'Novo\nCliente',
            color: theme.colorScheme.primary,
            onTap: () async {
              final criou = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => const ClienteFormScreen(),
                ),
              );
              if (criou == true) {
                ref.invalidate(clientesListProvider);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.inventory_2,
            label: 'Estoque',
            color: theme.colorScheme.tertiary,
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const EstoqueListScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClientesSection(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AsyncValue<List<Cliente>> clientesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Clientes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        clientesAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  error.toUserMessage('Erro ao carregar clientes'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
          data: (clientes) {
            if (clientes.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline,
                          size: 48, color: theme.colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum cliente cadastrado',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque em "Novo Cliente" para cadastrar.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final exibir = clientes.length > 5 ? clientes.take(5).toList() : clientes;

            return Column(
              children: [
                ...exibir.map(
                  (cliente) => ClienteTile(
                    cliente: cliente,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ClienteDetailScreen(clienteId: cliente.id),
                        ),
                      );
                    },
                  ),
                ),
                if (clientes.length > 5) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ClientesListScreen(),
                          ),
                        );
                      },
                      child: const Text('Ver todos os clientes →'),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: 3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
