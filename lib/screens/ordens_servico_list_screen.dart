import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/ordem_servico.dart';
import '../providers/providers.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions.dart';
import '../utils/status_os.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import 'ordem_servico_detail_screen.dart';
import 'nova_ordem_servico_screen.dart';

class OrdensServicoListScreen extends ConsumerStatefulWidget {
  const OrdensServicoListScreen({super.key});

  @override
  ConsumerState<OrdensServicoListScreen> createState() => _OrdensServicoListScreenState();
}

class _OrdensServicoListScreenState extends ConsumerState<OrdensServicoListScreen> {
  final _searchController = TextEditingController();
  String? _filtroStatus;
  String? _termoBusca;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordensAsync = ref.watch(ordensServicoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ordens de Serviço')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'nova_os',
        onPressed: () async {
          final criou = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) => const NovaOrdemServicoScreen(),
            ),
          );
          if (criou == true) {
            ref.invalidate(ordensServicoProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xs),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por cliente, placa ou OS',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _termoBusca = null);
                        },
                      )
                    : null,
              ),
              onSubmitted: (v) => setState(() => _termoBusca = v),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [
                _FiltroChip(
                  label: 'Todas',
                  selected: _filtroStatus == null,
                  onSelected: () => setState(() => _filtroStatus = null),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FiltroChip(
                  label: 'Abertas',
                  color: Colors.blue,
                  selected: _filtroStatus == 'aberta',
                  onSelected: () => setState(() => _filtroStatus = 'aberta'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FiltroChip(
                  label: 'Finalizadas',
                  color: Colors.green,
                  selected: _filtroStatus == 'finalizada',
                  onSelected: () => setState(() => _filtroStatus = 'finalizada'),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(ordensServicoProvider);
                await ref.read(ordensServicoProvider.future);
              },
              child: ordensAsync.when(
                loading: () => const LoadingIndicator(),
                error: (error, _) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    ErrorDisplay(message: error.toUserMessage('Erro ao carregar OS')),
                  ],
                ),
                data: (ordens) => _buildList(ordens),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<OrdemServico> ordens) {
    var filtradas = ordens.toList();

    if (_filtroStatus != null) {
      filtradas = filtradas.where((o) => o.status == _filtroStatus).toList();
    }
    if (_termoBusca != null && _termoBusca!.isNotEmpty) {
      final q = _termoBusca!.toLowerCase();
      filtradas = filtradas.where((o) =>
        o.clienteNome.toLowerCase().contains(q) ||
        (o.motoPlaca?.toLowerCase().contains(q) ?? false) ||
        o.id.toString().contains(q),
      ).toList();
    }

    if (filtradas.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 80),
          EmptyState(
            icon: Icons.assignment_outlined,
            title: 'Nenhuma Ordem de Serviço encontrada',
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: 88),
      itemCount: filtradas.length,
      itemBuilder: (context, index) => _OsCard(
        ordem: filtradas[index],
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OrdemServicoDetailScreen(ordemId: filtradas[index].id),
            ),
          );
          ref.invalidate(ordensServicoProvider);
        },
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  const _FiltroChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cor = color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: cor.withAlpha(25),
        checkmarkColor: cor,
        labelStyle: TextStyle(
          color: selected ? cor : null,
          fontWeight: selected ? FontWeight.w600 : null,
        ),
      ),
    );
  }
}

class _OsCard extends StatelessWidget {
  const _OsCard({required this.ordem, required this.onTap});

  final OrdemServico ordem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cor = statusOsColor(ordem.status, atrasada: ordem.isAtrasada);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cor.withAlpha(77)),
                    ),
                    child: Text(
                      '#${ordem.id}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusOsLabel(ordem.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cor,
                      ),
                    ),
                  ),
                  if (ordem.isAtrasada) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(Icons.warning, size: 14, color: theme.colorScheme.error),
                  ],
                  const Spacer(),
                  if (ordem.valorTotal > 0)
                    Text(
                      'R\$ ${ordem.valorTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ordem.clienteNome,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 2),
              if (ordem.motoDescricao != null)
                Text(
                  ordem.motoDescricao!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (ordem.mecanicoNome != null) ...[
                    Icon(Icons.person_outline, size: 14, color: theme.colorScheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      ordem.mecanicoNome!,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ] else if (ordem.mecanico != null) ...[
                    Icon(Icons.person_outline, size: 14, color: theme.colorScheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      ordem.mecanico!,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  if (ordem.prazo != null) ...[
                    Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(ordem.prazo!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ordem.isAtrasada ? theme.colorScheme.error : null,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
