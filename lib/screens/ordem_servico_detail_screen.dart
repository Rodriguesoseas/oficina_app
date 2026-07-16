import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../utils/currency.dart';
import '../utils/extensions.dart';

class OrdemServicoDetailScreen extends ConsumerWidget {
  const OrdemServicoDetailScreen({
    super.key,
    required this.ordemId,
  });

  final int ordemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordemAsync = ref.watch(ordemDetailProvider(ordemId));

    return Scaffold(
      appBar: AppBar(title: Text('OS #$ordemId')),
      body: ordemAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            error.toUserMessage('Erro ao carregar ordem de serviço'),
          ),
        ),
        data: (ordem) {
          final theme = Theme.of(context);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _InfoTile(label: 'Serviço', value: ordem.tipoServico?.nome ?? '#${ordem.tipoServicoId}'),
                      const Divider(),
                      _InfoTile(label: 'Status', value: ordem.status),
                      const Divider(),
                      _InfoTile(label: 'Cliente', value: ordem.tituloCliente),
                      const Divider(),
                      _InfoTile(label: 'Moto', value: ordem.tituloMoto),
                      const Divider(),
                      _InfoTile(label: 'Data', value: formatDateTime(ordem.createdAt)),
                      if (ordem.quilometragem != null) ...[
                        const Divider(),
                        _InfoTile(label: 'Quilometragem', value: '${ordem.quilometragem} km'),
                      ],
                      if (ordem.observacao != null && ordem.observacao!.isNotEmpty) ...[
                        const Divider(),
                        _InfoTile(label: 'Observação', value: ordem.observacao!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (ordem.itens.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                  child: Row(
                    children: [
                      Icon(Icons.build, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Peças', style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      )),
                    ],
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: ordem.itens.map((item) {
                      return ListTile(
                        title: Text(item.itemEstoque?.nome ?? 'Item #${item.itemEstoqueId}'),
                        subtitle: Text('${item.quantidade} x ${formatCurrency(item.precoUnitario)}'),
                        trailing: Text(formatCurrency(item.subtotal),
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text('Nenhuma peça utilizada',
                          style: TextStyle(color: Colors.grey[600])),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                color: theme.colorScheme.primaryContainer.withAlpha(60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _InfoTile(label: 'Peças', value: formatCurrency(ordem.valorPecas)),
                      const Divider(),
                      _InfoTile(label: 'Mão de obra', value: formatCurrency(ordem.valorMaoObra)),
                      const Divider(),
                      _InfoTile(label: 'Total', value: formatCurrency(ordem.valorTotal), destacado: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    this.destacado = false,
  });

  final String label;
  final String value;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: destacado
                  ? Theme.of(context).textTheme.titleMedium
                  : Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
