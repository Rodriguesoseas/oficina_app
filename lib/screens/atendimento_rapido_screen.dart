import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item_estoque.dart';
import '../models/tipo_servico.dart';
import '../providers/providers.dart';
import '../utils/extensions.dart';
import '../widgets/item_estoque_card.dart' show ItemEstoqueCard, ItemEstoqueCardMode;

class AtendimentoRapidoScreen extends ConsumerStatefulWidget {
  const AtendimentoRapidoScreen({
    super.key,
    required this.clienteId,
    required this.motoId,
    this.clienteNome,
    this.motoDescricao,
  });

  final int clienteId;
  final int motoId;
  final String? clienteNome;
  final String? motoDescricao;

  @override
  ConsumerState<AtendimentoRapidoScreen> createState() =>
      _AtendimentoRapidoScreenState();
}

class _AtendimentoRapidoScreenState
    extends ConsumerState<AtendimentoRapidoScreen> {
  final _valorMaoObraController = TextEditingController();
  final _quilometragemController = TextEditingController();
  final _observacaoController = TextEditingController();

  List<TipoServico> _tiposServico = [];
  List<ItemEstoque> _itensEstoque = [];
  final Map<int, int> _quantidades = {};
  TipoServico? _tipoSelecionado;
  bool _carregando = true;
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarCatalogos();
  }

  @override
  void dispose() {
    _valorMaoObraController.dispose();
    _quilometragemController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarCatalogos() async {
    try {
      final catalogo = ref.read(catalogoServiceProvider);
      final tipos = await catalogo.listarTiposServico();
      final itens = await catalogo.listarItensEstoque();

      setState(() {
        _tiposServico = tipos.where((tipo) => tipo.ativo).toList();
        _itensEstoque = itens.where((item) => item.ativo).toList();
        _tipoSelecionado = _tiposServico.isNotEmpty ? _tiposServico.first : null;
        _carregando = false;
      });
    } catch (error) {
      setState(() {
        _erro = error.toUserMessage('Erro ao carregar catálogos');
        _carregando = false;
      });
    }
  }

  Map<String, dynamic> _montarPayload() {
    final itens = _quantidades.entries
        .where((entry) => entry.value > 0)
        .map((entry) => {
              'item_estoque_id': entry.key,
              'quantidade': entry.value,
            })
        .toList();

    final payload = <String, dynamic>{
      'tipo_servico_id': _tipoSelecionado!.id,
      'itens': itens,
      'cliente_id': widget.clienteId,
      'moto_id': widget.motoId,
    };

    final valorMaoObra = double.tryParse(
      _valorMaoObraController.text.replaceAll(',', '.'),
    );
    if (valorMaoObra != null) {
      payload['valor_mao_obra'] = valorMaoObra;
    }

    final quilometragem = int.tryParse(_quilometragemController.text);
    if (quilometragem != null) {
      payload['quilometragem'] = quilometragem;
    }

    final observacao = _observacaoController.text.trim();
    if (observacao.isNotEmpty) {
      payload['observacao'] = observacao;
    }

    return payload;
  }

  Future<void> _salvar() async {
    if (_tipoSelecionado == null) {
      setState(() => _erro = 'Selecione um tipo de serviço');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      await ref
          .read(atendimentoServiceProvider)
          .criarRapido(_montarPayload());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atendimento registrado com sucesso')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      setState(() {
        _erro = error.toUserMessage('Erro ao salvar atendimento');
      });
    } finally {
      setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Novo Atendimento')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_erro != null) ...[
            Text(_erro!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
          ],
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(Icons.person,
                    color: Theme.of(context).colorScheme.primary),
              ),
              title: Text(widget.clienteNome ?? 'Cliente'),
              subtitle: Text(widget.motoDescricao ?? 'Moto'),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TipoServico>(
            initialValue: _tipoSelecionado,
            decoration: const InputDecoration(
              labelText: 'Tipo de serviço',
              border: OutlineInputBorder(),
            ),
            items: _tiposServico
                .map(
                  (tipo) => DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo.nome),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _tipoSelecionado = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _valorMaoObraController,
            decoration: const InputDecoration(
              labelText: 'Valor',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quilometragemController,
            decoration: const InputDecoration(
              labelText: 'Quilometragem',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _observacaoController,
            decoration: const InputDecoration(
              labelText: 'Observação',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Text('Peças', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._itensEstoque.map((item) => ItemEstoqueCard(
            modo: ItemEstoqueCardMode.selecao,
            item: item,
            quantidade: _quantidades[item.id] ?? 0,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            onIncrement: () => setState(() => _quantidades[item.id] = (_quantidades[item.id] ?? 0) + 1),
            onDecrement: () => setState(() => _quantidades[item.id] = (_quantidades[item.id] ?? 0) - 1),
          )),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _salvando ? null : _salvar,
            icon: _salvando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Registrar atendimento'),
          ),
        ],
      ),
    );
  }

}
