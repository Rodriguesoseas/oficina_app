import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cliente.dart';
import '../models/moto.dart';
import '../providers/providers.dart';
import '../utils/extensions.dart';
import 'cliente_form_screen.dart';
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          return Center(
            child: Text(error.toUserMessage('Erro ao carregar cliente')),
          );
        },
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
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cliente.nome,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
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
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.two_wheeler, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Motos (${cliente.motos.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () async {
                  final moto = await Navigator.of(context).push<Moto>(
                    MaterialPageRoute<Moto>(
                      builder: (_) => MotoFormScreen(clienteId: cliente.id),
                    ),
                  );
                  if (moto != null) {
                    ref.invalidate(clienteDetailProvider(clienteId));
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nova'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (cliente.motos.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.motorcycle_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhuma moto cadastrada',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...cliente.motos.map(
            (moto) => Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Icon(
                        Icons.two_wheeler,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            moto.descricao,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (moto.quilometragem != null) ...[
                                Icon(Icons.speed, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
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
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
