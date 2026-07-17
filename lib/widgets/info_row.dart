import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.valueBold = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: theme.colorScheme.outline),
            const SizedBox(width: AppSpacing.sm),
          ],
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: valueBold ? FontWeight.w600 : null,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}