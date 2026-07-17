import 'package:flutter/material.dart';

import '../models/item_estoque.dart';
import '../utils/currency.dart';
import 'status_badge.dart';

enum ItemEstoqueCardMode {
  selecao,
  gerencia,
}

class ItemEstoqueCard extends StatelessWidget {
  const ItemEstoqueCard({
    super.key,
    required this.item,
    required this.modo,
    this.quantidade,
    this.onIncrement,
    this.onDecrement,
    this.onTap,
    this.onEdit,
    this.onToggleActive,
    this.margin,
  });

  final ItemEstoque item;
  final ItemEstoqueCardMode modo;
  final int? quantidade;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleActive;
  final EdgeInsetsGeometry? margin;

  String get _textoEstoque {
    if (modo == ItemEstoqueCardMode.gerencia) {
      return '${item.quantidade} em estoque';
    }
    return 'Estoque: ${item.quantidade} unidade${item.quantidade != 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildProgressBar(context),
              const SizedBox(height: 8),
              _buildInfoRow(context),
              const SizedBox(height: 12),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (item.estoqueBaixo)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(Icons.warning, size: 18, color: theme.colorScheme.error),
          ),
        Expanded(
          child: Text(
            item.nome,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          formatCurrency(item.precoUnitario),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: modo == ItemEstoqueCardMode.gerencia
                ? theme.colorScheme.primary
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final theme = Theme.of(context);
    final cor = item.estoqueBaixo
        ? theme.colorScheme.error
        : item.quantidade < item.estoqueMinimo * 2
            ? theme.colorScheme.tertiary
            : theme.colorScheme.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: item.progressoNormalizado,
        backgroundColor: cor.withAlpha(25),
        valueColor: AlwaysStoppedAnimation(cor),
        minHeight: 8,
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          _textoEstoque,
          style: theme.textTheme.bodySmall,
        ),
        if (modo == ItemEstoqueCardMode.gerencia) ...[
          const SizedBox(width: 12),
          Text(
            'mín: ${item.estoqueMinimo}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
        const Spacer(),
        if (item.estoqueBaixo)
          StatusBadge(
            label: 'ESTOQUE BAIXO!',
            color: theme.colorScheme.error,
            size: StatusBadgeSize.sm,
          )
        else if (item.quantidade < item.estoqueMinimo * 2)
          StatusBadge(
            label: 'Atenção',
            color: theme.colorScheme.tertiary,
            size: StatusBadgeSize.sm,
          )
        else
          StatusBadge(
            label: 'OK',
            color: theme.colorScheme.primary,
            size: StatusBadgeSize.sm,
          ),
      ],
    );
  }


  Widget _buildActionButtons(BuildContext context) {
    switch (modo) {
      case ItemEstoqueCardMode.selecao:
        return _buildSelecaoButtons(context);
      case ItemEstoqueCardMode.gerencia:
        return _buildGerenciaButtons(context);
    }
  }

  Widget _buildSelecaoButtons(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: (quantidade ?? 0) > 0 ? onDecrement : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${quantidade ?? 0}',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: (quantidade ?? 0) < item.quantidade ? onIncrement : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildGerenciaButtons(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(Icons.edit_outlined,
              size: 20, color: theme.colorScheme.primary),
          tooltip: 'Editar',
          onPressed: onEdit,
        ),
        IconButton(
          icon: Icon(Icons.delete_outline,
              size: 20, color: theme.colorScheme.error),
          tooltip: 'Desativar',
          onPressed: onToggleActive,
        ),
      ],
    );
  }
}
