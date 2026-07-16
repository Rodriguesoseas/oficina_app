import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item_estoque.dart';
import '../providers/providers.dart';
import '../utils/extensions.dart';
import '../widgets/item_estoque_card.dart';
import 'estoque_form_screen.dart';

class EstoqueListScreen extends ConsumerWidget {
  const EstoqueListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itensAsync = ref.watch(itensEstoqueProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estoque')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'novo_item_estoque',
        onPressed: () async {
          final criou = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) => const EstoqueFormScreen(),
            ),
          );
          if (criou == true) {
            ref.invalidate(itensEstoqueProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(itensEstoqueProvider);
          await ref.read(itensEstoqueProvider.future);
        },
        child: itensAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    error.toUserMessage('Erro ao carregar estoque'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
          data: (itens) => _EstoqueListContent(itens: itens),
        ),
      ),
    );
  }
}

class _EstoqueListContent extends StatelessWidget {
  const _EstoqueListContent({required this.itens});

  final List<ItemEstoque> itens;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itensBaixos = itens.where((i) => i.estoqueBaixo).length;

    if (itens.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Nenhum item no estoque',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Toque em + para cadastrar o primeiro.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final grouped = <String, List<ItemEstoque>>{};
    for (final item in itens) {
      grouped.putIfAbsent(item.categoria, () => []).add(item);
    }

    final categoriasOrdenadas = grouped.keys.toList()..sort();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${itens.length} itens cadastrados',
                          style: theme.textTheme.titleSmall,
                        ),
                        if (itensBaixos > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  size: 16, color: theme.colorScheme.error),
                              const SizedBox(width: 4),
                              Text(
                                '$itensBaixos com estoque baixo',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ...categoriasOrdenadas.map((categoria) {
          final items = grouped[categoria]!;
          return _CategoriaSection(
            categoria: categoria,
            itens: items,
            total: items.length,
          );
        }),
      ],
    );
  }
}

class _CategoriaSection extends StatelessWidget {
  const _CategoriaSection({
    required this.categoria,
    required this.itens,
    required this.total,
  });

  final String categoria;
  final List<ItemEstoque> itens;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
          child: Row(
            children: [
              Icon(_categoriaIcon(categoria), size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                categoria,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$total',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...itens.map((item) => Consumer(builder: (context, ref, _) {
          return ItemEstoqueCard(
            item: item,
            modo: ItemEstoqueCardMode.gerencia,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            onEdit: () async {
              final editou = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => EstoqueFormScreen(item: item),
                ),
              );
              if (editou == true) {
                ref.invalidate(itensEstoqueProvider);
              }
            },
            onToggleActive: () async {
              final confirmou = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Desativar item'),
                  content: Text(
                    'Tem certeza que deseja desativar "${item.nome}"?\n\n'
                    'Itens desativados não aparecem no catálogo de peças do atendimento.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Desativar'),
                    ),
                  ],
                ),
              );
              if (confirmou == true) {
                try {
                  await ref
                      .read(catalogoServiceProvider)
                      .atualizarItemEstoque(item.id, {'ativo': false});
                  ref.invalidate(itensEstoqueProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item desativado')),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            error.toUserMessage('Erro ao desativar item')),
                      ),
                    );
                  }
                }
              }
            },
          );
        })),
      ],
    );
  }

  IconData _categoriaIcon(String cat) {
    switch (cat) {
      case 'oleo':
        return Icons.oil_barrel;
      case 'filtro':
        return Icons.filter_alt;
      case 'pastilha':
      case 'lona':
        return Icons.disc_full;
      case 'relacao':
        return Icons.settings_suggest;
      case 'pneu':
        return Icons.circle;
      case 'cabos':
        return Icons.cable;
      case 'velas':
        return Icons.bolt;
      case 'bateria':
        return Icons.battery_charging_full;
      default:
        return Icons.inventory_2;
    }
  }
}
