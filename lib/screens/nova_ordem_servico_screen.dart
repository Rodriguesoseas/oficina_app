import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/cliente.dart';
import '../models/item_estoque.dart';
import '../models/moto.dart';
import '../models/ordem_servico.dart';
import '../providers/providers.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions.dart';
import '../widgets/empty_state.dart';
import '../widgets/saving_button.dart';
import 'moto_form_screen.dart';

class _ItemSelecionado {
  const _ItemSelecionado({
    required this.itemEstoqueId,
    required this.nome,
    required this.quantidade,
    required this.precoUnitario,
  });

  final int itemEstoqueId;
  final String nome;
  final int quantidade;
  final double precoUnitario;

  double get subtotal => quantidade * precoUnitario;
}

class NovaOrdemServicoScreen extends ConsumerStatefulWidget {
  const NovaOrdemServicoScreen({
    super.key,
    this.clienteId,
    this.motoId,
    this.ordem,
  });

  final int? clienteId;
  final int? motoId;
  final OrdemServico? ordem;

  @override
  ConsumerState<NovaOrdemServicoScreen> createState() => _NovaOrdemServicoScreenState();
}

class _NovaOrdemServicoScreenState extends ConsumerState<NovaOrdemServicoScreen> {
  static const _stepLabels = ['Cliente', 'Moto', 'Problema', 'Peças', 'Prazo', 'Revisão'];

  int _currentStep = 0;
  bool _salvando = false;
  bool _carregandoInicial = true;

  Cliente? _clienteSelecionado;
  Moto? _motoSelecionada;
  final _problemaController = TextEditingController();
  final _prazoController = TextEditingController();
  final _observacoesController = TextEditingController();
  DateTime? _prazo;
  final _pageController = PageController();
  final _itensSelecionados = <_ItemSelecionado>[];

  @override
  void initState() {
    super.initState();
    if (widget.ordem != null) {
      _preencherParaEdicao();
    } else if (widget.clienteId != null || widget.motoId != null) {
      _carregarDadosIniciais();
    } else {
      _carregandoInicial = false;
    }
  }

  void _preencherParaEdicao() {
    final os = widget.ordem!;
    _problemaController.text = os.problema ?? '';
    _observacoesController.text = os.observacoes ?? '';
    _prazo = os.prazo;
    if (_prazo != null) {
      _prazoController.text = DateFormat('dd/MM/yyyy').format(_prazo!);
    }
    if (os.clienteId > 0) {
      _carregarDadosIniciais(clienteId: os.clienteId, motoId: os.motoId);
    } else {
      setState(() => _carregandoInicial = false);
    }
  }

  Future<void> _carregarDadosIniciais({int? clienteId, int? motoId}) async {
    final cid = clienteId ?? widget.clienteId;
    final mid = motoId ?? widget.motoId;
    try {
      if (cid != null) {
        final cliente = await ref.read(clienteServiceProvider).detalhe(cid);
        _clienteSelecionado = cliente;

        if (mid != null) {
          final motoResumo = cliente.motos.where((m) => m.id == mid).firstOrNull;
          if (motoResumo != null) {
            _motoSelecionada = Moto(
              id: motoResumo.id,
              clienteId: motoResumo.clienteId,
              marca: motoResumo.marca,
              modelo: motoResumo.modelo,
              placa: motoResumo.placa,
              quilometragem: motoResumo.quilometragem,
              ano: motoResumo.ano,
              clienteNome: _clienteSelecionado?.nome,
            );
          }
        }
      }
    } catch (_) {
    }
    if (mounted) {
      setState(() {
        _carregandoInicial = false;
        if (_clienteSelecionado != null) _currentStep = 1;
        if (_motoSelecionada != null) _currentStep = 2;
        _pageController.jumpToPage(_currentStep);
      });
    }
  }

  @override
  void dispose() {
    _problemaController.dispose();
    _prazoController.dispose();
    _observacoesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool get _podeAvancar {
    switch (_currentStep) {
      case 0: return _clienteSelecionado != null;
      case 1: return true;
      case 2: return _problemaController.text.trim().isNotEmpty;
      case 3: return true;
      case 4: return _prazo != null;
      default: return true;
    }
  }

  Future<void> _salvar() async {
    if (_clienteSelecionado == null) return;
    final isEditando = widget.ordem != null;
    setState(() => _salvando = true);
    try {
      final data = <String, dynamic>{
        'cliente_id': _clienteSelecionado!.id,
        if (_motoSelecionada != null) 'moto_id': _motoSelecionada!.id,
        'problema': _problemaController.text.trim(),
        'prazo': _prazo?.toIso8601String(),
        if (_observacoesController.text.trim().isNotEmpty)
          'observacao': _observacoesController.text.trim(),
        if (_itensSelecionados.isNotEmpty)
          'item_ordem_servicos_attributes': _itensSelecionados
              .map((i) => {
                    'item_estoque_id': i.itemEstoqueId,
                    'quantidade': i.quantidade,
                  })
              .toList(),
      };

      if (isEditando) {
        await ref.read(ordemServicoServiceProvider).atualizar(widget.ordem!.id, data);
      } else {
        await ref.read(ordemServicoServiceProvider).criar(data);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditando ? 'OS atualizada com sucesso!' : 'Ordem de Serviço criada com sucesso!'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toUserMessage('Erro ao ${isEditando ? "atualizar" : "criar"} OS')),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = _stepLabels;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ordem != null ? 'Editar OS #${widget.ordem!.id}' : 'Nova Ordem de Serviço'),
        bottom: _carregandoInicial
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: _buildStepIndicator(theme, steps),
              ),
      ),
      body: _carregandoInicial
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _stepCliente(),
                _stepMoto(),
                _stepProblema(),
                _stepPecas(),
                _stepPrazo(),
                _stepRevisao(),
              ],
            ),
          ),
          _buildNavigation(theme),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme, List<String> steps) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final isActive = index == _currentStep;
          final isDone = index < _currentStep;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? theme.colorScheme.primary
                        : isActive
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 16,
                    height: 2,
                    color: isDone
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigation(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('Voltar'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _currentStep < _stepLabels.length - 1
                  ? FilledButton(
                      onPressed: _podeAvancar
                          ? () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                          : null,
                      child: const Text('Avançar'),
                    )
                  : SavingButton(
                      label: 'Salvar OS',
                      onPressed: _salvar,
                      isSaving: _salvando,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepCliente() {
    final clientesAsync = ref.watch(clientesListProvider);
    return clientesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Erro ao carregar clientes')),
      data: (clientes) {
        if (clientes.isEmpty) {
          return const EmptyState(
            icon: Icons.people_outline,
            title: 'Nenhum cliente cadastrado',
            subtitle: 'Cadastre um cliente primeiro.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: clientes.length,
          itemBuilder: (context, index) {
            final c = clientes[index];
            final selecionado = _clienteSelecionado?.id == c.id;
            return Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                onTap: () async {
                  final completo = await ref.read(clienteServiceProvider).detalhe(c.id);
                  if (mounted) {
                    setState(() {
                      _clienteSelecionado = completo;
                      _motoSelecionada = null;
                    });
                  }
                },
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person, color: selecionado ? Colors.white : null),
                  ),
                  title: Text(c.nome),
                  subtitle: Text(c.telefone ?? 'Sem telefone'),
                  trailing: selecionado
                      ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _stepMoto() {
    if (_clienteSelecionado == null) {
      return const Center(child: Text('Selecione um cliente primeiro'));
    }

    final tema = Theme.of(context);
    final motos = _clienteSelecionado!.motos;

    if (motos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmptyState(
              icon: Icons.motorcycle_outlined,
              title: 'Nenhuma moto cadastrada',
              subtitle: 'Cadastre uma moto para este cliente.',
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => _cadastrarMoto(),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Moto'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        ...motos.map((m) {
          final selecionada = _motoSelecionada?.id == m.id;
          return Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InkWell(
              onTap: () => setState(() => _motoSelecionada = Moto(
                id: m.id,
                clienteId: m.clienteId,
                marca: m.marca,
                modelo: m.modelo,
                placa: m.placa,
                quilometragem: m.quilometragem,
                ano: m.ano,
                clienteNome: _clienteSelecionado?.nome,
              )),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: tema.colorScheme.secondaryContainer,
                  child: Icon(Icons.two_wheeler, color: tema.colorScheme.secondary),
                ),
                title: Text(m.descricao),
                subtitle: m.quilometragem != null ? Text('${m.quilometragem} km') : null,
                trailing: selecionada
                    ? Icon(Icons.check_circle, color: tema.colorScheme.primary)
                    : null,
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () => _cadastrarMoto(),
          icon: const Icon(Icons.add),
          label: const Text('Cadastrar outra moto'),
        ),
      ],
    );
  }

  Future<void> _cadastrarMoto() async {
    final moto = await Navigator.of(context).push<Moto>(
      MaterialPageRoute<Moto>(
        builder: (_) => MotoFormScreen(clienteId: _clienteSelecionado!.id),
      ),
    );
    if (moto != null) {
      final clienteAtualizado = await ref.read(clienteServiceProvider).detalhe(_clienteSelecionado!.id);
      if (mounted) {
        setState(() {
          _clienteSelecionado = clienteAtualizado;
          _motoSelecionada = moto;
        });
      }
    }
  }

  Future<void> _mostrarSelecaoItens() async {
    final itemSelecionado = await showModalBottomSheet<ItemEstoque>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _SelecionarItemSheet(),
    );
    if (itemSelecionado == null || !mounted) return;
    _pedirQuantidade(itemSelecionado);
  }

  Future<void> _pedirQuantidade(ItemEstoque item) async {
    final quantidade = await showDialog<int>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: '1');
        return AlertDialog(
          title: Text('Quantidade: ${item.nome}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantidade',
              hintText: '1',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final qtd = int.tryParse(controller.text);
                if (qtd != null && qtd > 0) Navigator.pop(context, qtd);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
    if (quantidade == null || !mounted) return;
    setState(() {
      _itensSelecionados.add(_ItemSelecionado(
        itemEstoqueId: item.id,
        nome: item.nome,
        quantidade: quantidade,
        precoUnitario: item.precoUnitario,
      ));
    });
  }

  Widget _stepPecas() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          FilledButton.icon(
            onPressed: _mostrarSelecaoItens,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Peça'),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _itensSelecionados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Nenhuma peça adicionada',
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text('Toque em "Adicionar Peça" para incluir itens.',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _itensSelecionados.length,
                    itemBuilder: (context, index) {
                      final item = _itensSelecionados[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          title: Text(item.nome),
                          subtitle: Text(
                              '${item.quantidade}x R\$ ${item.precoUnitario.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'R\$ ${item.subtotal.toStringAsFixed(2)}',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => setState(
                                    () => _itensSelecionados.removeAt(index)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _stepProblema() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          TextFormField(
            controller: _problemaController,
            decoration: const InputDecoration(
              labelText: 'Problema informado',
              hintText: 'Descreva o problema relatado pelo cliente',
              prefixIcon: Icon(Icons.report_problem),
            ),
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _stepPrazo() {
    final theme = Theme.of(context);
    final mecanicoNome = ref.watch(authProvider).mecanico?.nome ?? '---';
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Text('Definir Prazo de Entrega', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Selecione a data de entrega para prosseguir',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: theme.colorScheme.outline),
                      const SizedBox(width: 8),
                      Text(
                        'Mecânico: $mecanicoNome',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _prazoController,
                    decoration: const InputDecoration(
                      labelText: 'Data de entrega',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final data = await showDatePicker(
                        context: context,
                        initialDate: _prazo ?? DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (data != null) {
                        setState(() {
                          _prazo = data;
                          _prazoController.text = DateFormat('dd/MM/yyyy').format(data);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepRevisao() {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumo da OS', style: theme.textTheme.titleMedium),
                const Divider(),
                _resumoRow(theme, 'Cliente', _clienteSelecionado?.nome ?? ''),
                _resumoRow(theme, 'Moto', _motoSelecionada?.descricao ?? 'Sem moto'),
                _resumoRow(theme, 'Problema', _problemaController.text),
                _resumoRow(
                  theme,
                  'Mecânico',
                  ref.watch(authProvider).mecanico?.nome ?? '---',
                ),
                if (_prazo != null)
                  _resumoRow(theme, 'Prazo', DateFormat('dd/MM/yyyy').format(_prazo!)),
                if (_itensSelecionados.isNotEmpty) ...[
                  const Divider(),
                  Text('Peças', style: theme.textTheme.titleSmall),
                  ..._itensSelecionados.map((i) => _resumoRow(
                    theme,
                    '${i.quantidade}x ${i.nome}',
                    'R\$ ${i.subtotal.toStringAsFixed(2)}',
                  )),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextFormField(
          controller: _observacoesController,
          decoration: const InputDecoration(
            labelText: 'Observações',
            prefixIcon: Icon(Icons.notes),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _resumoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _SelecionarItemSheet extends ConsumerStatefulWidget {
  const _SelecionarItemSheet();

  @override
  ConsumerState<_SelecionarItemSheet> createState() => _SelecionarItemSheetState();
}

class _SelecionarItemSheetState extends ConsumerState<_SelecionarItemSheet> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itensAsync = ref.watch(itensEstoqueProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Selecionar Peça', style: theme.textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar peça...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _search = v.toLowerCase()),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: itensAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erro ao carregar estoque')),
                data: (itens) {
                  final filtrados = _search.isEmpty
                      ? itens
                      : itens
                          .where((i) => i.nome.toLowerCase().contains(_search))
                          .toList();
                  if (filtrados.isEmpty) {
                    return const Center(child: Text('Nenhum item encontrado'));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: filtrados.length,
                    itemBuilder: (context, index) {
                      final item = filtrados[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          child: Icon(Icons.inventory_2,
                              color: theme.colorScheme.secondary),
                        ),
                        title: Text(item.nome),
                        subtitle: Text(
                            'R\$ ${item.precoUnitario.toStringAsFixed(2)}  •  Estoque: ${item.quantidade}'),
                        onTap: () => Navigator.pop(context, item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}