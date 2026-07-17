import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../screens/agenda_screen.dart';
import '../screens/clientes_list_screen.dart';
import '../screens/configuracoes_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/estoque_list_screen.dart';
import '../screens/gerenciar_mecanicos_screen.dart';
import '../screens/ordens_servico_list_screen.dart';
import '../theme/app_spacing.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _screens = const [
      DashboardScreen(),
      OrdensServicoListScreen(),
      ClientesListScreen(embedded: true),
      EstoqueListScreen(),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recarregarTudo();
    }
  }

  void _recarregarTudo() {
    ref.invalidate(dashboardProvider);
    ref.invalidate(ordensServicoProvider);
    ref.invalidate(clientesListProvider);
    ref.invalidate(itensEstoqueProvider);
    ref.invalidate(agendaProvider);
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0: ref.invalidate(dashboardProvider);
      case 1: ref.invalidate(ordensServicoProvider);
      case 2: ref.invalidate(clientesListProvider);
      case 3: ref.invalidate(itensEstoqueProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.mecanico;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.two_wheeler, size: 40, color: theme.colorScheme.primary),
                  const SizedBox(height: AppSpacing.sm),
                  Text('A2M Motos', style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  )),
                  Text('Sistema de Gestão', style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  )),
                  if (user != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: theme.colorScheme.onPrimaryContainer),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${user.nome} (${user.isAdmin ? "Admin" : "Mecânico"})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            _DrawerItem(Icons.dashboard, 'Dashboard', () => _navigateToTab(0)),
            _DrawerItem(Icons.assignment, 'Ordens de Serviço', () => _navigateToTab(1)),
            _DrawerItem(Icons.people, 'Clientes', () => _navigateToTab(2)),
            _DrawerItem(Icons.inventory_2, 'Estoque', () => _navigateToTab(3)),
            const Divider(),
            _DrawerItem(Icons.calendar_month, 'Agenda', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendaScreen()));
            }),
            if (authState.isAdmin) ...[
              _DrawerItem(Icons.admin_panel_settings, 'Gerenciar Mecânicos', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GerenciarMecanicosScreen()));
              }),
            ],
            _DrawerItem(Icons.settings, 'Configurações', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfiguracoesScreen()));
            }),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(darkModeProvider.notifier).update((state) => !state);
            },
            icon: Icon(
              ref.watch(darkModeProvider) ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: 'Alternar tema',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Ordens',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Estoque',
          ),
        ],
      ),
    );
  }

  void _navigateToTab(int index) {
    Navigator.pop(context);
    _onTabSelected(index);
  }
}

final _titles = const [
  'A2M Motos',
  'Ordens de Serviço',
  'Clientes',
  'Estoque',
];

class _DrawerItem extends StatelessWidget {
  const _DrawerItem(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}
