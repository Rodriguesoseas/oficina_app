import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item_estoque.dart';
import '../models/tipo_servico.dart';
import '../providers/providers.dart';
import '../utils/extensions.dart';
import '../widgets/item_estoque_card.dart' show ItemEstoqueCard, ItemEstoqueCardMode;

class AtendimentoAvulsoScreen extends ConsumerStatefulWidget {
  const AtendimentoAvulsoScreen({super.key});

  @override
  ConsumerState<AtendimentoAvulsoScreen> createState() =>
      _AtendimentoAvulsoScreenState();
}

class _AtendimentoAvulsoScreenState
    extends ConsumerState<AtendimentoAvulsoScreen> {
  final _avulsoNomeController = TextEditingController();
  final _avulsoTelefoneController = TextEditingController();
  final _avulsoMotoController = TextEditingController();
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
    _avulsoNomeController.dispose();
    _avulsoTelefoneController.dispose();
    _avulsoMotoController.dispose();
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
      'modo': 'avulso',
      'tipo_servico_id': _tipoSelecionado!.id,
      'itens': itens,
      'avulso': {
        'nome': _avulsoNomeController.text.trim(),
        'telefone': _avulsoTelefoneController.text.trim(),
        'moto_descricao': _avulsoMotoController.text.trim(),
      },
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
    final theme = Theme.of(context);

    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Atendimento Avulso')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_erro != null) ...[
            Text(_erro!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
          ],
          _buildSection(
            color: theme.colorScheme.primary,
            title: 'Dados do Cliente',
            icon: Icons.person,
            child: Column(
              children: [
                TextField(
                  controller: _avulsoNomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _avulsoTelefoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _avulsoMotoController,
                  decoration: const InputDecoration(
                    labelText: 'Moto',
                    hintText: 'Ex: Honda CG 160',
                    prefixIcon: Icon(Icons.two_wheeler),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSection(
            color: Colors.grey,
            title: 'Serviço',
            icon: Icons.build,
            child: Column(
              children: [
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
                    labelText: 'Valor da mão de obra',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quilometragemController,
                  decoration: const InputDecoration(
                    labelText: 'Quilometragem',
                    prefixIcon: Icon(Icons.speed),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _observacaoController,
                  decoration: const InputDecoration(
                    labelText: 'Observação',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSection(
            color: Colors.green,
            title: 'Peças',
            icon: Icons.inventory_2,
            child: _itensEstoque.isEmpty
                ? Text('Nenhum item disponível',
                    style: TextStyle(color: Colors.grey[600]))
                : Column(
                    children: _itensEstoque.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ItemEstoqueCard(
                        modo: ItemEstoqueCardMode.selecao,
                        item: item,
                        quantidade: _quantidades[item.id] ?? 0,
                        margin: EdgeInsets.zero,
                        onIncrement: () => setState(() => _quantidades[item.id] = (_quantidades[item.id] ?? 0) + 1),
                        onDecrement: () => setState(() => _quantidades[item.id] = (_quantidades[item.id] ?? 0) - 1),
                      ),
                    )).toList(),
                  ),
          ),
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
            label: const Text('Registrar Atendimento'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection({
    required Color color,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: color.withAlpha(20),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }


}
