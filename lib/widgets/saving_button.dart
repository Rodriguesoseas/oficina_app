import 'package:flutter/material.dart';

class SavingButton extends StatelessWidget {
  const SavingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSaving = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isSaving;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isSaving ? null : onPressed,
      icon: isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon ?? Icons.check),
      label: Text(label),
    );
  }
}
