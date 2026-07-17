import 'package:flutter/material.dart';

import '../models/moto.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class MotoCard extends StatelessWidget {
  const MotoCard({
    super.key,
    required this.moto,
    this.onTap,
    this.onAbrirOs,
    this.showCliente = false,
  });

  final Moto moto;
  final VoidCallback? onTap;
  final VoidCallback? onAbrirOs;
  final bool showCliente;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.motorcycle,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${moto.marca} ${moto.modelo}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                moto.placa,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            if (showCliente && moto.clienteNome != null) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Icon(Icons.person_outline, size: 13, color: theme.colorScheme.outline),
                              const SizedBox(width: 3),
                              Text(
                                moto.clienteNome!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onAbrirOs != null)
                    FilledButton.tonalIcon(
                      onPressed: onAbrirOs,
                      icon: const Icon(Icons.build_outlined, size: 16),
                      label: const Text('OS', style: TextStyle(fontSize: 12)),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _buildInfoChip(context, icon: Icons.speed, text: '${moto.quilometragem ?? 0} km'),
                  if (moto.ano != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _buildInfoChip(context, icon: Icons.calendar_today, text: '${moto.ano}'),
                  ],
                  if (moto.proximaRevisaoKm != null) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withAlpha(77)),
                      ),
                      child: Text(
                        'Revisão: ${moto.proximaRevisaoKm} km',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {required IconData icon, required String text}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}