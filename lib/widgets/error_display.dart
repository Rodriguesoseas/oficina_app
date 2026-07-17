import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
