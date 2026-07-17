import 'package:flutter/material.dart';

import '../models/ordem_servico.dart';
import '../theme/app_spacing.dart';
import '../utils/currency.dart';
import '../utils/status_os.dart';

class OsCard extends StatelessWidget {
  const OsCard({
    super.key,
    required this.ordem,
    this.onTap,
    this.onDelete,
  });

  final OrdemServico ordem;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cor = statusOsColor(ordem.status, atrasada: ordem.isAtrasada);
    final label = statusOsLabel(ordem.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 4,
              color: cor,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cor.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cor.withAlpha(77)),
                        ),
                        child: Text(
                          label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: cor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '#${ordem.id}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const Spacer(),
                      if (ordem.isAtrasada)
                        Icon(Icons.warning_amber_rounded, size: 18, color: theme.colorScheme.error),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ordem.clienteNome,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  if (ordem.motoDescricao != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.motorcycle_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          ordem.motoDescricao!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                  if (ordem.prazo != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.event_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          'Entrega: ${ordem.prazo!.day.toString().padLeft(2, '0')}/${ordem.prazo!.month.toString().padLeft(2, '0')}/${ordem.prazo!.year}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        formatCurrency(ordem.valorTotal),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
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
    );
  }
}