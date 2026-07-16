import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item_estoque.dart';
import '../providers/providers.dart';
import '../utils/extensions.dart';
import '../widgets/form_section_card.dart';

const _categorias = [
  'oleo', 'filtro', 'pastilha', 'lona', 'relacao',
  'pneu', 'cabos', 'velas', 'bateria',
];

class EstoqueFormScreen extends ConsumerStatefulWidget {
  const EstoqueFormScreen({super.key, this.item});

  final ItemEstoque? item;

  @override
  ConsumerState<EstoqueFormScreen> createState() => _EstoqueFormScreenState();
}

class _EstoqueFormScreenState extends ConsumerState<EstoqueFormScreen> {
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _estoqueMinimoController = TextEditingController();
  final _precoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _categoria = _categorias.first;
  bool _ativo = true;
  bool _salvando = false;
  bool get _editando => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      final item = widget.item!;
      _nomeController.text = item.nome;
      _categoria = item.categoria;
      _quantidadeController.text = item.quantidade.toString();
      _estoqueMinimoController.text = item.estoqueMinimo.toString();
      _precoController.text = item.precoUnitario.toStringAsFixed(2);
      _ativo = item.ativo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _estoqueMinimoController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final data = <String, dynamic>{
        'nome': _nomeController.text.trim(),
        'categoria': _categoria,
        'quantidade': int.tryParse(_quantidadeController.text) ?? 0,
        'estoque_minimo': int.tryParse(_estoqueMinimoController.text) ?? 0,
        'preco_unitario': double.tryParse(
          _precoController.text.replaceAll(',', '.'),
        ),
        'ativo': _ativo,
      };

      if (_editando) {
        await ref
            .read(catalogoServiceProvider)
            .atualizarItemEstoque(widget.item!.id, data);
      } else {
        await ref.read(catalogoServiceProvider).criarItemEstoque(data);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editando
              ? 'Item atualizado com sucesso'
              : 'Item cadastrado com sucesso'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toUserMessage('Erro ao salvar item')),
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Item' : 'Novo Item'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: FormSectionCard(
              spacing: 20,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do item',
                    hintText: 'Ex: Óleo 1L, Filtro de Óleo...',
                    prefixIcon: Icon(Icons.label),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _categoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.folder),
                    border: OutlineInputBorder(),
                  ),
                  items: _categorias.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _categoria = v);
                  },
                ),
                TextFormField(
                  controller: _quantidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade em estoque',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _estoqueMinimoController,
                  decoration: const InputDecoration(
                    labelText: 'Estoque mínimo',
                    prefixIcon: Icon(Icons.warning_amber),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _precoController,
                  decoration: const InputDecoration(
                    labelText: 'Preço unitário (R\$)',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ativo', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text('Sim'),
                          icon: Icon(Icons.check_circle, size: 16),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text('Não'),
                          icon: Icon(Icons.cancel, size: 16),
                        ),
                      ],
                      selected: {_ativo},
                      onSelectionChanged: (v) {
                        setState(() => _ativo = v.first);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _salvando ? null : _salvar,
            icon: _salvando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_editando ? 'Atualizar Item' : 'Salvar Item'),
          ),
        ],
      ),
    );
  }
}
