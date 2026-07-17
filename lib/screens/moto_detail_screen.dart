import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/moto.dart';
import '../providers/providers.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/section_header.dart';
import 'nova_ordem_servico_screen.dart';

class MotoDetailScreen extends ConsumerWidget {
  const MotoDetailScreen({
    super.key,
    required this.motoId,
    this.clienteNome,
  });

  final int motoId;
  final String? clienteNome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motoAsync = ref.watch(motoDetailProvider(motoId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moto'),
      ),
      body: motoAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorDisplay(
          message: error.toUserMessage('Erro ao carregar moto'),
        ),
        data: (moto) => _MotoDetailContent(moto: moto, clienteNome: clienteNome),
      ),
    );
  }
}

class _MotoDetailContent extends ConsumerWidget {
  const _MotoDetailContent({
    required this.moto,
    this.clienteNome,
  });

  final Moto moto;
  final String? clienteNome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.two_wheeler,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${moto.marca} ${moto.modelo}',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        moto.placa,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.xs,
                        children: [
                          if (moto.ano != null)
                            _InfoChip(
                              icon: Icons.calendar_today,
                              label: '${moto.ano}',
                            ),
                          if (moto.quilometragem != null)
                            _InfoChip(
                              icon: Icons.speed,
                              label: '${moto.quilometragem} km',
                            ),
                          if (clienteNome != null)
                            _InfoChip(
                              icon: Icons.person,
                              label: clienteNome!,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () async {
                  final os = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NovaOrdemServicoScreen(motoId: moto.id),
                    ),
                  );
                  if (os != null) {
                    ref.invalidate(motoDetailProvider(moto.id));
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Nova Ordem de Serviço'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        if (moto.proximaRevisaoKm != null) ...[
          Card(
            color: theme.colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.build_circle, color: theme.colorScheme.tertiary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Próxima revisão',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                        Text(
                          '${moto.proximaRevisaoKm} km',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
        if (moto.urlFoto != null) ...[
          SectionHeader(icon: Icons.photo_library, title: 'Fotos'),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                moto.urlFoto!,
                width: 240,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 240,
                  height: 160,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.broken_image, color: theme.colorScheme.outline),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
        SectionHeader(
          icon: Icons.history,
          title: 'Linha do tempo',
          count: moto.timeline.length,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (moto.timeline.isEmpty)
          const EmptyState(
            icon: Icons.history,
            title: 'Nenhum registro no histórico',
          )
        else
          ...moto.timeline.map((event) => _TimelineCard(event: event)),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.outline),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.event});

  final TimelineEvent event;

  IconData _iconePorTipo() {
    switch (event.tipo) {
      case 'revisao':
        return Icons.build_circle;
      case 'garantia':
        return Icons.verified;
      case 'servico':
        return Icons.handyman;
      case 'peca':
        return Icons.precision_manufacturing;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(
                _iconePorTipo(),
                size: 20,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.titulo, style: theme.textTheme.titleSmall),
                  if (event.descricao != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        event.descricao!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (event.data != null)
                          Text(
                            event.data!.toLocal().toString().split(' ')[0],
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        if (event.km != null)
                          Text(
                            '${event.km} km',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        if (event.valor != null)
                          Text(
                            'R\$ ${event.valor!.toStringAsFixed(2)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
