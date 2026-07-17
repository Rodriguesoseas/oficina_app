import 'package:flutter/material.dart';

import '../models/item_estoque.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/currency.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onToggleActive,
    this.quantidadeSelecionada,
    this.onIncrement,
    this.onDecrement,
  });

  final ItemEstoque item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleActive;
  final int? quantidadeSelecionada;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  Color get _progressColor {
    if (item.estoqueBaixo) return Colors.red;
    if (item.quantidade < item.estoqueMinimo * 2) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icone = AppColors.categoriaIcon[item.categoria] ?? Icons.inventory_2_outlined;

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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _progressColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(icone, size: 22, color: _progressColor),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nome,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.categoria.isNotEmpty)
                          Text(
                            item.categoria[0].toUpperCase() + item.categoria.substring(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatCurrency(item.precoUnitario),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (quantidadeSelecionada != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Qtd: $quantidadeSelecionada',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.progressoNormalizado.clamp(0.0, 1.0),
                  backgroundColor: _progressColor.withAlpha(25),
                  valueColor: AlwaysStoppedAnimation(_progressColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    '${item.quantidade} un${item.quantidade != 1 ? 's' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'mín: ${item.estoqueMinimo}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const Spacer(),
                  if (item.estoqueBaixo)
                    _buildBadge(theme, 'ESTOQUE BAIXO', Colors.red)
                  else if (item.quantidade < item.estoqueMinimo * 2)
                    _buildBadge(theme, 'ATENÇÃO', Colors.orange)
                  else
                    _buildBadge(theme, 'OK', Colors.green),
                  if (onEdit != null || onToggleActive != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 18, color: theme.colorScheme.outline),
                      onSelected: (v) {
                        if (v == 'edit') onEdit?.call();
                        if (v == 'toggle') onToggleActive?.call();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(item.ativo ? 'Desativar' : 'Ativar'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              if (quantidadeSelecionada != null && onIncrement != null && onDecrement != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _quantityButton(context, Icons.remove_circle_outline, onDecrement,
                          enabled: quantidadeSelecionada! > 0),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$quantidadeSelecionada',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      _quantityButton(context, Icons.add_circle_outline, onIncrement,
                          enabled: quantidadeSelecionada! < item.quantidade),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _quantityButton(BuildContext context, IconData icon, VoidCallback? onPressed,
      {required bool enabled}) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 24),
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(4),
        minimumSize: const Size(36, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}