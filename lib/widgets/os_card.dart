import 'package:flutter/material.dart';

import '../models/ordem_servico.dart';
import '../utils/currency.dart';

class OsCard extends StatelessWidget {
  const OsCard({
    super.key,
    required this.ordem,
    required this.onTap,
    this.onDelete,
  });

  final OrdemServico ordem;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  Color _statusColor(String status) {
    switch (status) {
      case 'concluido':
        return Colors.green;
      case 'em_andamento':
        return Colors.blue;
      case 'aberto':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _servicoIcon(String nome) {
    switch (nome.toLowerCase()) {
      case _ when nome.contains('óleo') || nome.contains('oleo'):
        return Icons.oil_barrel;
      case _ when nome.contains('revis') || nome.contains('revisão'):
        return Icons.build;
      case _ when nome.contains('freio'):
        return Icons.disc_full;
      case _ when nome.contains('relação') || nome.contains('relacao'):
        return Icons.settings_suggest;
      case _ when nome.contains('pneu'):
        return Icons.circle;
      case _ when nome.contains('elétri') || nome.contains('eletri'):
        return Icons.bolt;
      default:
        return Icons.handyman;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(ordem.status);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(width: 5, height: 120, color: statusColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      radius: 22,
                      child: Icon(
                        _servicoIcon(ordem.tipoServico?.nome ?? ''),
                        size: 22,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  ordem.tipoServico?.nome ?? 'Serviço #${ordem.tipoServicoId}',
                                  style: theme.textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                formatCurrency(ordem.valorTotal),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ordem.tituloCliente,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            ordem.tituloMoto,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withAlpha(38),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ordem.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatDateTime(ordem.createdAt),
                                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                              ),
                              const Spacer(),
                              if (onDelete != null)
                                SizedBox(
                                  height: 32,
                                  width: 32,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(Icons.delete_outline, size: 18,
                                        color: theme.colorScheme.error),
                                    onPressed: onDelete,
                                    tooltip: 'Excluir',
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
