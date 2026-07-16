import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cliente.dart';
import '../providers/providers.dart';
import '../utils/extensions.dart';
import '../widgets/cliente_tile.dart';
import 'cliente_detail_screen.dart';
import 'cliente_form_screen.dart';

class ClientesListScreen extends ConsumerStatefulWidget {
  const ClientesListScreen({super.key});

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou telefone',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                error.toUserMessage('Erro ao carregar clientes'),
                                textAlign: TextAlign.center,
                              ),
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
                              Icon(Icons.people_outline, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Nenhum cliente cadastrado',
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Toque em + para cadastrar o primeiro.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 4),
                          itemCount: clientes.length,
                          itemBuilder: (context, index) {
                            final cliente = clientes[index];
                            return ClienteTile(
                              cliente: cliente,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ClienteDetailScreen(clienteId: cliente.id),
                                  ),
                                );
                                ref.invalidate(clientesListProvider);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultadosBusca() {
    if (_buscando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(_erro!, textAlign: TextAlign.center),
      );
    }

    if (_resultados.isEmpty) {
      return const Center(child: Text('Nenhum cliente encontrado'));
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4),
      itemCount: _resultados.length,
      itemBuilder: (context, index) {
        final cliente = _resultados[index];
        return ClienteTile(
          cliente: cliente,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ClienteDetailScreen(clienteId: cliente.id),
              ),
            );
            ref.invalidate(clientesListProvider);
          },
        );
      },
    );
  }
}
