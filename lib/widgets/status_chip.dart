import 'package:flutter/material.dart';

enum StatusChipSize { sm, md, lg }

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.size = StatusChipSize.sm,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final StatusChipSize size;

  @override
  Widget build(BuildContext context) {
    final isSm = size == StatusChipSize.sm;
    final isMd = size == StatusChipSize.md;
    final fontSize = isSm ? 10.0 : (isMd ? 12.0 : 13.0);
    final iconSize = isSm ? 14.0 : (isMd ? 16.0 : 18.0);
    final hPad = isSm ? 8.0 : (isMd ? 10.0 : 12.0);
    final vPad = isSm ? 3.0 : (isMd ? 4.0 : 6.0);
    final radius = isSm ? 8.0 : (isMd ? 10.0 : 12.0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}