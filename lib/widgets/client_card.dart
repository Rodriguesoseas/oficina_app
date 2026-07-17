import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../theme/app_spacing.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({
    super.key,
    required this.cliente,
    this.onTap,
    this.onDelete,
  });

  final Cliente cliente;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  Color _avatarColor(String nome) {
    final hash = nome.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.5, 0.6).toColor();
  }

  String _initials(String nome) {
    final parts = nome.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return nome.isNotEmpty ? nome[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarColor = _avatarColor(cliente.nome);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: avatarColor,
                child: Text(
                  _initials(cliente.nome),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nome,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (cliente.telefone != null)
                      Row(
                        children: [
                          Icon(Icons.call_outlined, size: 13, color: theme.colorScheme.outline),
                          const SizedBox(width: 4),
                          Text(
                            cliente.telefone!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.motorcycle_outlined, size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${cliente.motos.length} moto${cliente.motos.length != 1 ? 's' : ''}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (cliente.motos.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.outline,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.check_circle, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Ativo',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: theme.colorScheme.outline),
                onSelected: (value) {
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}