import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cliente.dart';
import '../models/moto.dart';
import '../providers/providers.dart';
import '../utils/extensions.dart';
import '../theme/app_spacing.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/section_header.dart';
import 'cliente_form_screen.dart';
import 'moto_detail_screen.dart';
import 'moto_form_screen.dart';

class ClienteDetailScreen extends ConsumerWidget {
  const ClienteDetailScreen({
    super.key,
    required this.clienteId,
  });

  final int clienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalheAsync = ref.watch(clienteDetailProvider(clienteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () async {
              final cliente = detalheAsync.valueOrNull;
              if (cliente == null) return;

              final editou = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => ClienteFormScreen(cliente: cliente),
                ),
              );
              if (editou == true) {
                ref.invalidate(clienteDetailProvider(clienteId));
              }
            },
          ),
        ],
      ),
      body: detalheAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorDisplay(
          message: error.toUserMessage('Erro ao carregar cliente'),
        ),
        data: (cliente) => _ClienteDetailContent(cliente: cliente, clienteId: clienteId),
      ),
    );
  }
}

class _ClienteDetailContent extends ConsumerWidget {
  const _ClienteDetailContent({
    required this.cliente,
    required this.clienteId,
  });

  final Cliente cliente;
  final int clienteId;

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
                  radius: 32,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cliente.nome,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: theme.colorScheme.outline),
                          const SizedBox(width: 4),
                          Text(
                            cliente.telefone ?? 'Sem telefone',
                            style: theme.textTheme.bodyMedium,
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
        SectionHeader(
          icon: Icons.two_wheeler,
          title: 'Motos',
          count: cliente.motos.length,
          actionLabel: 'Nova',
          onAction: () async {
            final moto = await Navigator.of(context).push<Moto>(
              MaterialPageRoute<Moto>(
                builder: (_) => MotoFormScreen(clienteId: cliente.id),
              ),
            );
            if (moto != null) {
              ref.invalidate(clienteDetailProvider(clienteId));
            }
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        if (cliente.motos.isEmpty)
          EmptyState(
            icon: Icons.motorcycle_outlined,
            title: 'Nenhuma moto cadastrada',
          )
        else
          ...cliente.motos.map(
            (moto) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MotoDetailScreen(
                        motoId: moto.id,
                        clienteNome: cliente.nome,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Icon(
                          Icons.two_wheeler,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              moto.descricao,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                if (moto.quilometragem != null) ...[
                                  Icon(Icons.speed, size: 14, color: theme.colorScheme.outline),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    '${moto.quilometragem} km',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
