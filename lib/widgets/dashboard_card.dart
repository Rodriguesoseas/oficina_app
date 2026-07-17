import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class DashboardCard extends StatefulWidget {
  const DashboardCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color,
    this.onTap,
    this.gradient,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final List<Color>? gradient;

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cor = widget.color ?? theme.colorScheme.primary;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: widget.onTap != null ? (_) => setState(() {}) : null,
          child: Container(
            decoration: widget.gradient != null
                ? BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.gradient!,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  )
                : null,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cor.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(widget.icon, size: 24, color: cor),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: widget.gradient != null ? Colors.white : cor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: widget.gradient != null
                        ? Colors.white.withAlpha(200)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      icon: icon,
      value: value,
      label: label,
      color: color,
      onTap: onTap,
    );
  }
}