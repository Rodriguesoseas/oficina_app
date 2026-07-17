import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item_estoque.dart';
import '../providers/providers.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import 'estoque_form_screen.dart';

class ProdutoDetailScreen extends ConsumerWidget {
  const ProdutoDetailScreen({super.key, required this.itemId});

  final int itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemEstoqueDetailProvider(itemId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () async {
              final item = itemAsync.valueOrNull;
              if (item == null) return;
              final editou = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => EstoqueFormScreen(item: item),
                ),
              );
              if (editou == true) {
                ref.invalidate(itemEstoqueDetailProvider(itemId));
                ref.invalidate(itensEstoqueProvider);
              }
            },
          ),
        ],
      ),
      body: itemAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorDisplay(
          message: error.toUserMessage('Erro ao carregar produto'),
        ),
        data: (item) => _ProdutoDetailContent(item: item),
      ),
    );
  }
}

class _ProdutoDetailContent extends StatelessWidget {
  const _ProdutoDetailContent({required this.item});

  final ItemEstoque item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: _corCategoria(theme).withValues(alpha: 0.15),
                  child: Icon(
                    _iconeCategoria(),
                    size: 32,
                    color: _corCategoria(theme),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.nome, style: theme.textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.categoria,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${item.precoUnitario.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _StatusChip(
                      quantidade: item.quantidade,
                      estoqueBaixo: item.estoqueBaixo,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.inventory_2,
                label: 'Em estoque',
                value: '${item.quantidade} un',
                color: item.estoqueBaixo
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _InfoTile(
                icon: Icons.warning_amber,
                label: 'Estoque mínimo',
                value: '${item.estoqueMinimo} un',
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        if (item.ativo == false) ...[
          const SizedBox(height: AppSpacing.sm),
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.block, size: 18, color: theme.colorScheme.error),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Produto inativo',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  IconData _iconeCategoria() {
    switch (item.categoria.toLowerCase()) {
      case 'oleo':
      case 'lubrificante':
        return Icons.oil_barrel;
      case 'pneu':
        return Icons.radio_button_checked;
      case 'filtro':
        return Icons.air;
      case 'freio':
        return Icons.circle;
      case 'corrente':
        return Icons.link;
      case 'peca':
        return Icons.precision_manufacturing;
      case 'acessorio':
        return Icons.star;
      default:
        return Icons.inventory_2;
    }
  }

  Color _corCategoria(ThemeData theme) {
    switch (item.categoria.toLowerCase()) {
      case 'oleo':
      case 'lubrificante':
        return Colors.amber.shade700;
      case 'pneu':
        return Colors.blueGrey;
      case 'filtro':
        return Colors.cyan;
      case 'freio':
        return Colors.red.shade700;
      case 'peca':
        return theme.colorScheme.primary;
      case 'acessorio':
        return Colors.purple;
      default:
        return theme.colorScheme.primary;
    }
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.quantidade, required this.estoqueBaixo});

  final int quantidade;
  final bool estoqueBaixo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (quantidade <= 0) {
      return Chip(
        label: const Text('Sem estoque'),
        visualDensity: VisualDensity.compact,
        backgroundColor: theme.colorScheme.errorContainer,
        labelStyle: TextStyle(fontSize: 12, color: theme.colorScheme.onErrorContainer),
        side: BorderSide.none,
      );
    }
    if (estoqueBaixo) {
      return Chip(
        label: const Text('Estoque baixo'),
        visualDensity: VisualDensity.compact,
        backgroundColor: theme.colorScheme.tertiaryContainer,
        labelStyle: TextStyle(fontSize: 12, color: theme.colorScheme.onTertiaryContainer),
        side: BorderSide.none,
      );
    }
    return Chip(
      label: const Text('Disponível'),
      visualDensity: VisualDensity.compact,
      backgroundColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer),
      side: BorderSide.none,
    );
  }
}


