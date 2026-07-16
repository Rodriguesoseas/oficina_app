import 'package:flutter/material.dart';

class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    super.key,
    required this.children,
    this.spacing = 20,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}
