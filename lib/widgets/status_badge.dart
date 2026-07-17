import 'package:flutter/material.dart';

enum StatusBadgeSize { sm, md }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.size = StatusBadgeSize.sm,
  });

  final String label;
  final Color color;
  final StatusBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final isSm = size == StatusBadgeSize.sm;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSm ? 8 : 12,
        vertical: isSm ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(isSm ? 8 : 12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: isSm ? 10 : 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
