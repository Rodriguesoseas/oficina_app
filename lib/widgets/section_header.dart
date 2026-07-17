import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.count,
    this.actionLabel,
    this.onAction,
    this.color,
  });

  final IconData icon;
  final String title;
  final int? count;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cor = color ?? theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cor,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cor.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cor,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (actionLabel != null && onAction != null)
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 18),
              label: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
