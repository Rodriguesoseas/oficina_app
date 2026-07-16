import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 12,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cor = color ?? theme.colorScheme.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: cor.withAlpha(20),
            child: Row(
              children: [
                Icon(icon, size: 18, color: cor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: padding,
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  if (i > 0) SizedBox(height: spacing),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
