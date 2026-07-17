import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/dashboard_data.dart';
import '../providers/providers.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/os_card.dart';
import '../widgets/section_title.dart';
import 'cliente_form_screen.dart';
import 'nova_ordem_servico_screen.dart';
import 'ordem_servico_detail_screen.dart';
import 'ordens_servico_list_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _refresh();
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(dashboardProvider);
    await ref.read(dashboardProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateFormat = DateFormat("EEEE, dd 'de' MMMM 'de' yyyy", 'pt_BR');
    final timeFormat = DateFormat('HH:mm');

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 88),
        children: [
          _buildHeader(theme, now, dateFormat, timeFormat),
          const SizedBox(height: AppSpacing.xl),
          _buildQuickActions(theme),
          const SizedBox(height: AppSpacing.xl),
          dashboardAsync.when(
            loading: () => const LoadingIndicator(),
            error: (error, _) => ErrorDisplay(
              message: error.toUserMessage('Erro ao carregar'),
            ),
            data: (data) => Column(
              children: [
                _buildMetricGrid(context, theme, data),
                const SizedBox(height: AppSpacing.xl),
                _buildUltimasOsSection(context, theme, data),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, DateTime now, DateFormat dateFormat, DateFormat timeFormat) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A2M Motos',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Olá!',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            dateFormat.format(now),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                timeFormat.format(now),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            icon: Icons.flash_on,
            title: 'Ações Rápidas',
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.assignment_add,
                  label: 'Nova OS',
                  color: theme.colorScheme.primary,
                  onTap: () async {
                    final criou = await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => const NovaOrdemServicoScreen(),
                      ),
                    );
                    if (criou == true) {
                      _refresh();
                      ref.invalidate(agendaProvider);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.person_add,
                  label: 'Cliente',
                  color: theme.colorScheme.secondary,
                  onTap: () async {
                    final criou = await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => const ClienteFormScreen(),
                      ),
                    );
                    if (criou == true) {
                      _refresh();
                      ref.invalidate(clientesListProvider);
                    }
                  },
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(BuildContext context, ThemeData theme, DashboardData data) {
    final largura = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            icon: Icons.analytics_outlined,
            title: 'Indicadores',
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 150,
            child: DashboardCard(
              icon: Icons.motorcycle,
              value: '${data.motosNaOficina}',
              label: 'Motos na Oficina',
              color: theme.colorScheme.primary,
              gradient: [theme.colorScheme.primary.withAlpha(200), theme.colorScheme.primary],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrdensServicoListScreen()),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              SizedBox(
                width: (largura - 40 - 20) / 3,
                height: 150,
                child: DashboardCard(
                  icon: Icons.check_circle,
                  value: '${data.entregasHoje}',
                  label: 'Entregas Hoje',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: (largura - 40 - 20) / 3,
                height: 150,
                child: DashboardCard(
                  icon: Icons.inventory_2_outlined,
                  value: '${data.itensEstoqueBaixo}',
                  label: 'Estoque Baixo',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: (largura - 40 - 20) / 3,
                height: 150,
                child: DashboardCard(
                  icon: Icons.attach_money,
                  value: 'R\$${data.faturamentoDia.toStringAsFixed(0)}',
                  label: 'Faturamento Hoje',
                  color: Colors.green.shade700,
                  gradient: [Colors.green.shade600, Colors.green.shade800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUltimasOsSection(
    BuildContext context,
    ThemeData theme,
    DashboardData data,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            icon: Icons.assignment,
            title: 'Últimas Ordens de Serviço',
            actionLabel: 'Ver todas',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OrdensServicoListScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (data.ultimasOS.isEmpty)
            const Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.assignment_outlined, size: 48),
                    SizedBox(height: 12),
                    Text('Nenhuma Ordem de Serviço'),
                  ],
                ),
              ),
            )
          else
            ...data.ultimasOS.take(5).map((os) => OsCard(
              ordem: os,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => OrdemServicoDetailScreen(ordemId: os.id)),
              ),
            )),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: color, width: 3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
