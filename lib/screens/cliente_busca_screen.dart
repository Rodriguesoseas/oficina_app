import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cliente.dart';
import '../models/moto.dart';
import '../providers/providers.dart';
import '../utils/extensions.dart';
import '../widgets/cliente_tile.dart';
import '../widgets/moto_tile.dart';
import 'atendimento_screen.dart';
import 'clientes_list_screen.dart';

class ClienteBuscaScreen extends ConsumerStatefulWidget {
  const ClienteBuscaScreen({super.key});

  @override
  ConsumerState<ClienteBuscaScreen> createState() => _ClienteBuscaScreenState();
}

class _ClienteBuscaScreenState extends ConsumerState<ClienteBuscaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _clienteQueryController = TextEditingController();
  final _placaController = TextEditingController();

  List<Cliente> _clientes = [];
  List<Moto> _motos = [];
  String? _erro;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _clienteQueryController.dispose();
    _placaController.dispose();
    super.dispose();
  }

  Future<void> _buscarClientes() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final resultados = await ref
          .read(clienteServiceProvider)
          .buscar(_clienteQueryController.text.trim());
      setState(() => _clientes = resultados);
    } catch (error) {
      setState(() {
        _erro = error.toUserMessage('Erro ao buscar clientes');
        _clientes = [];
      });
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _buscarMotos() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final resultados = await ref
          .read(motoServiceProvider)
          .buscarPorPlaca(_placaController.text.trim());
      setState(() => _motos = resultados);
    } catch (error) {
      setState(() {
        _erro = error.toUserMessage('Erro ao buscar motos');
        _motos = [];
      });
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _abrirAtendimentoComCliente(Cliente cliente) async {
    final detalhe = await ref.read(clienteServiceProvider).detalhe(cliente.id);
    if (!mounted) return;

    if (detalhe.motos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente sem motos cadastradas')),
      );
      return;
    }

    final moto = detalhe.motos.length == 1
        ? detalhe.motos.first
        : await showModalBottomSheet<MotoResumo>(
            context: context,
            builder: (context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ListTile(title: Text('Selecione a moto')),
                    ...detalhe.motos.map(
                      (moto) => ListTile(
                        title: Text(moto.descricao),
                        onTap: () => Navigator.pop(context, moto),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

    if (moto == null || !mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => AtendimentoScreen(
          clienteId: cliente.id,
          motoId: moto.id,
          clienteNome: cliente.nome,
          motoDescricao: moto.descricao,
        ),
      ),
    );
  }

  Future<void> _abrirAtendimentoComMoto(Moto moto) async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => AtendimentoScreen(
          clienteId: moto.clienteId,
          motoId: moto.id,
          clienteNome: moto.clienteNome,
          motoDescricao: moto.descricao,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cliente'),
            Tab(text: 'Placa'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'novo_cliente_busca',
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ClientesListScreen(),
            ),
          );
        },
        child: const Icon(Icons.person_add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClienteTab(),
          _buildMotoTab(),
        ],
      ),
    );
  }

  Widget _buildClienteTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _clienteQueryController,
            decoration: InputDecoration(
              hintText: 'Nome ou telefone',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _carregando ? null : _buscarClientes,
              ),
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _buscarClientes(),
          ),
        ),
        if (_erro != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_erro!, style: const TextStyle(color: Colors.red)),
          ),
        Expanded(child: _buildResultadoClientes()),
      ],
    );
  }

  Widget _buildMotoTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _placaController,
            decoration: InputDecoration(
              hintText: 'Placa da moto',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _carregando ? null : _buscarMotos,
              ),
            ),
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => _buscarMotos(),
          ),
        ),
        if (_erro != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_erro!, style: const TextStyle(color: Colors.red)),
          ),
        Expanded(child: _buildResultadoMotos()),
      ],
    );
  }

  Widget _buildResultadoClientes() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_clientes.isEmpty) {
      return const Center(child: Text('Busque um cliente para iniciar'));
    }

    return ListView.builder(
      itemCount: _clientes.length,
      itemBuilder: (context, index) {
        final cliente = _clientes[index];
        return ClienteTile(
          cliente: cliente,
          onTap: () => _abrirAtendimentoComCliente(cliente),
        );
      },
    );
  }

  Widget _buildResultadoMotos() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_motos.isEmpty) {
      return const Center(child: Text('Busque uma placa para iniciar'));
    }

    return ListView.builder(
      itemCount: _motos.length,
      itemBuilder: (context, index) {
        final moto = _motos[index];
        return MotoTile(
          moto: moto,
          onTap: () => _abrirAtendimentoComMoto(moto),
        );
      },
    );
  }
}
