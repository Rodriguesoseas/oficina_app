import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mecanico.dart';
import '../providers/providers.dart';
import '../theme/app_spacing.dart';

class GerenciarMecanicosScreen extends ConsumerStatefulWidget {
  const GerenciarMecanicosScreen({super.key});

  @override
  ConsumerState<GerenciarMecanicosScreen> createState() =>
      _GerenciarMecanicosScreenState();
}

class _GerenciarMecanicosScreenState
    extends ConsumerState<GerenciarMecanicosScreen> {
  List<Mecanico> _mecanicos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final lista = await authService.listarMecanicos();
      if (mounted) setState(() => _mecanicos = lista);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _adicionar() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => const _AdicionarMecanicoDialog(),
    );
    if (result == null || !mounted) return;
    try {
      final authService = ref.read(authServiceProvider);
      await authService.criarMecanico(
        nome: result['nome']!,
        email: result['email']!,
        password: result['password']!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mecânico cadastrado com sucesso!')),
      );
      _carregar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Mecânicos')),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionar,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregar,
              child: _mecanicos.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.person_outline, size: 48),
                              SizedBox(height: 16),
                              Text('Nenhum mecânico cadastrado'),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: _mecanicos.length,
                      itemBuilder: (context, index) {
                        final m = _mecanicos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: m.isAdmin
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.secondaryContainer,
                              child: Icon(
                                m.isAdmin ? Icons.admin_panel_settings : Icons.person,
                                color: m.isAdmin
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.secondary,
                              ),
                            ),
                            title: Text(m.nome),
                            subtitle: Text(m.email),
                            trailing: Chip(
                              label: Text(
                                m.isAdmin ? 'Admin' : 'Mecânico',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: m.isAdmin
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.secondary,
                                ),
                              ),
                              backgroundColor: m.isAdmin
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.secondaryContainer,
                              side: BorderSide.none,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

class _AdicionarMecanicoDialog extends StatefulWidget {
  const _AdicionarMecanicoDialog();

  @override
  State<_AdicionarMecanicoDialog> createState() =>
      _AdicionarMecanicoDialogState();
}

class _AdicionarMecanicoDialogState extends State<_AdicionarMecanicoDialog> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Mecânico'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Nome do mecânico',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'email@exemplo.com',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                hintText: 'Mínimo 6 caracteres',
              ),
              validator: (v) =>
                  v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'nome': _nomeController.text.trim(),
                'email': _emailController.text.trim(),
                'password': _passwordController.text,
              });
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
