import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/ordem_servico.dart';
import '../providers/providers.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions.dart';
import '../utils/status_os.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/section_header.dart';
import 'nova_ordem_servico_screen.dart';

class OrdemServicoDetailScreen extends ConsumerWidget {
  const OrdemServicoDetailScreen({
    super.key,
    required this.ordemId,
  });

  final int ordemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final osAsync = ref.watch(ordemServicoDetailProvider(ordemId));

    return Scaffold(
      appBar: AppBar(
        title: Text('OS #$ordemId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () async {
              final os = osAsync.valueOrNull;
              if (os == null) return;
              final editou = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => NovaOrdemServicoScreen(ordem: os),
                ),
              );
              if (editou == true && context.mounted) {
                ref.invalidate(ordemServicoDetailProvider(ordemId));
                ref.invalidate(agendaProvider);
              }
            },
          ),
          if (osAsync.valueOrNull?.isAberta == true)
            IconButton(
              icon: const Icon(Icons.check_circle),
              tooltip: 'Finalizar',
              onPressed: () async {
                final os = osAsync.valueOrNull;
                if (os == null) return;
                final confirmou = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Finalizar OS?'),
                    content: const Text('Tem certeza que deseja finalizar esta ordem de serviço?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Finalizar'),
                      ),
                    ],
                  ),
                );
                if (confirmou != true) return;
                try {
                  await ref.read(ordemServicoServiceProvider).alterarStatus(
                    os.id,
                    'finalizada',
                  );
                  if (!context.mounted) return;
                  ref.invalidate(ordemServicoDetailProvider(ordemId));
                  ref.invalidate(agendaProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OS finalizada com sucesso!')),
                  );
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao finalizar OS')),
                  );
                }
              },
            ),
          if (osAsync.valueOrNull?.isFinalizada == true)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reabrir',
              onPressed: () async {
                final os = osAsync.valueOrNull;
                if (os == null) return;
                final confirmou = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reabrir OS?'),
                    content: const Text('Tem certeza que deseja reabrir esta ordem de serviço?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Reabrir'),
                      ),
                    ],
                  ),
                );
                if (confirmou != true) return;
                try {
                  await ref.read(ordemServicoServiceProvider).alterarStatus(
                    os.id,
                    'aberta',
                  );
                  if (!context.mounted) return;
                  ref.invalidate(ordemServicoDetailProvider(ordemId));
                  ref.invalidate(agendaProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OS reaberta com sucesso!')),
                  );
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao reabrir OS')),
                  );
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar',
            onPressed: () {
              final os = osAsync.valueOrNull;
              if (os == null) return;
              final texto = StringBuffer()
                ..writeln('OS #${os.id}')
                ..writeln('Cliente: ${os.clienteNome}')
                ..writeln('Status: ${statusOsLabel(os.status)}')
                ..writeln('Valor: R\$ ${os.valorTotal.toStringAsFixed(2)}');
              if (os.motoDescricao != null) {
                texto.writeln('Moto: ${os.motoDescricao}');
              }
              if (os.mecanico != null) {
                texto.writeln('Mecânico: ${os.mecanico}');
              }
              if (os.problema != null) {
                texto.writeln('Problema: ${os.problema}');
              }
              Clipboard.setData(ClipboardData(text: texto.toString()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dados da OS copiados para a área de transferência')),
              );
            },
          ),
        ],
      ),
      body: osAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorDisplay(
          message: error.toUserMessage('Erro ao carregar OS'),
        ),
        data: (os) => _OrdemServicoDetailContent(os: os),
      ),
    );
  }
}

class _OrdemServicoDetailContent extends StatelessWidget {
  const _OrdemServicoDetailContent({required this.os});

  final OrdemServico os;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final cor = statusOsColor(os.status, atrasada: os.isAtrasada);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cor.withAlpha(77)),
                      ),
                      child: Text(
                        '#${os.id} - ${statusOsLabel(os.status)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: cor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (os.valorTotal > 0)
                      Text(
                        'R\$ ${os.valorTotal.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _infoRow(theme, Icons.person, 'Cliente', os.clienteNome),
                if (os.motoDescricao != null)
                  _infoRow(theme, Icons.motorcycle, 'Moto', os.motoDescricao!),
                if (os.mecanicoNome != null)
                  _infoRow(theme, Icons.build, 'Mecânico', os.mecanicoNome!),
                if (os.mecanico != null && os.mecanicoNome == null)
                  _infoRow(theme, Icons.build, 'Mecânico', os.mecanico!),
                if (os.prazo != null)
                  _infoRow(
                    theme,
                    Icons.calendar_today,
                    'Prazo',
                    dateFormat.format(os.prazo!),
                    cor: os.isAtrasada ? theme.colorScheme.error : null,
                  ),
                if (os.dataEntrada != null)
                  _infoRow(theme, Icons.login, 'Entrada', dateFormat.format(os.dataEntrada!)),
                if (os.dataSaida != null)
                  _infoRow(theme, Icons.logout, 'Saída', dateFormat.format(os.dataSaida!)),
              ],
            ),
          ),
        ),
        if (os.problema != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Problema Informado', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(os.problema!, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
        if (os.diagnostico != null) ...[
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Diagnóstico', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(os.diagnostico!, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
        if (os.checklist.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Checklist', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  ...os.checklist.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(item, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
        if (os.servicos.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(icon: Icons.build, title: 'Serviços', count: os.servicos.length),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: os.servicos.map((s) => ListTile(
                title: Text(s.nome),
                trailing: Text('R\$ ${s.valorTotal.toStringAsFixed(2)}'),
              )).toList(),
            ),
          ),
        ],
        if (os.pecas.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(icon: Icons.inventory_2, title: 'Peças', count: os.pecas.length),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: os.pecas.map((p) => ListTile(
                title: Text(p.nome),
                subtitle: Text('${p.quantidade}x'),
                trailing: Text('R\$ ${p.valorTotal.toStringAsFixed(2)}'),
              )).toList(),
            ),
          ),
        ],
        if (os.observacoes != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Observações', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(os.observacoes!, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value, {Color? cor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.outline),
          const SizedBox(width: AppSpacing.sm),
          Text('$label: ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(color: cor),
            ),
          ),
        ],
      ),
    );
  }
}
