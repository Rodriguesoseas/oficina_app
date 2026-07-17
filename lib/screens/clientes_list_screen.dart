import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cliente.dart';
import '../providers/providers.dart';
import '../utils/extensions.dart';
import '../theme/app_spacing.dart';
import '../widgets/client_card.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import 'cliente_detail_screen.dart';
import 'cliente_form_screen.dart';

class ClientesListScreen extends ConsumerStatefulWidget {
  const ClientesListScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<ClientesListScreen> createState() => _ClientesListScreenState();
}

class _ClientesListScreenState extends ConsumerState<ClientesListScreen> {
  final _searchController = TextEditingController();
  List<Cliente> _resultados = [];
  String? _erro;
  bool _buscando = false;
  bool _usouBusca = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    final termo = _searchController.text.trim();
    if (termo.isEmpty) {
      setState(() {
        _usouBusca = false;
        _resultados = [];
      });
      return;
    }

    setState(() {
      _buscando = true;
      _erro = null;
      _usouBusca = true;
    });

    try {
      final resultados = await ref
          .read(clienteServiceProvider)
          .buscar(termo);
      setState(() => _resultados = resultados);
    } catch (error) {
      setState(() {
        _erro = error.toUserMessage('Erro ao buscar');
        _resultados = [];
      });
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesListProvider);
    final body = _buildBody(clientesAsync);

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'novo_cliente_lista',
        onPressed: () async {
          final criou = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) => const ClienteFormScreen(),
            ),
          );
          if (criou == true) {
            ref.invalidate(clientesListProvider);
          }
        },
        child: const Icon(Icons.person_add),
      ),
      body: body,
    );
  }

  Widget _buildBody(AsyncValue<List<Cliente>> clientesAsync) {
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xs),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou telefone',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _usouBusca = false;
                            _resultados = [];
                          });
                        },
                      )
                    : null,
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _buscar(),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: _buscando ? null : _buscar,
                  icon: _buscando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search, size: 18),
                  label: const Text('Buscar'),
                ),
              ),
            ),
          Expanded(
            child: _usouBusca
                ? _buildResultadosBusca()
                : RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(clientesListProvider);
                      await ref.read(clientesListProvider.future);
                    },
                    child: clientesAsync.when(
                      loading: () => const LoadingIndicator(),
                      error: (error, _) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            ErrorDisplay(
                              message: error.toUserMessage('Erro ao carregar clientes'),
                            ),
                          ],
                        );
                      },
                      data: (clientes) {
                        if (clientes.isEmpty) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 80),
                              EmptyState(
                                icon: Icons.people_outline,
                                title: 'Nenhum cliente cadastrado',
                                subtitle: 'Toque em + para cadastrar o primeiro.',
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          itemCount: clientes.length,
                          itemBuilder: (context, index) {
                            final cliente = clientes[index];
                            return ClientCard(
                              cliente: cliente,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ClienteDetailScreen(clienteId: cliente.id),
                                  ),
                                );
                                ref.invalidate(clientesListProvider);
                              },
                              onDelete: () => _confirmarExclusao(cliente),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      );
  }

  Widget _buildResultadosBusca() {
    if (_buscando) {
      return const LoadingIndicator();
    }

    if (_erro != null) {
      return ErrorDisplay(message: _erro!);
    }

    if (_resultados.isEmpty) {
      return const Center(child: EmptyState(
        icon: Icons.search_off,
        title: 'Nenhum cliente encontrado',
      ));
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4),
      itemCount: _resultados.length,
      itemBuilder: (context, index) {
        final cliente = _resultados[index];
        return ClientCard(
          cliente: cliente,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ClienteDetailScreen(clienteId: cliente.id),
              ),
            );
            ref.invalidate(clientesListProvider);
          },
          onDelete: () => _confirmarExclusao(cliente),
        );
      },
    );
  }

  Future<void> _confirmarExclusao(Cliente cliente) async {
    final confirmou = await showConfirmDialog(
      context,
      title: 'Excluir cliente',
      message: 'Tem certeza que deseja excluir ${cliente.nome}?\n\n'
          'As motos serão removidas e as ordens de serviço ficarão sem vínculo.',
      confirmLabel: 'Excluir',
    );
    if (!confirmou || !mounted) return;

    try {
      await ref.read(clienteServiceProvider).deletar(cliente.id);
      if (!mounted) return;
      ref.invalidate(clientesListProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${cliente.nome} excluído com sucesso')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toUserMessage('Erro ao excluir cliente')),
        ),
      );
    }
  }
}
