import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.padding});

  final double? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding ?? AppSpacing.section),
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
