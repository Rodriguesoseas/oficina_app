import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cliente.dart';
import '../providers/providers.dart';
import '../utils/extensions.dart';
import '../theme/app_spacing.dart';
import '../widgets/form_section_card.dart';
import '../widgets/saving_button.dart';

class ClienteFormScreen extends ConsumerStatefulWidget {
  const ClienteFormScreen({super.key, this.cliente});

  final Cliente? cliente;

  @override
  ConsumerState<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends ConsumerState<ClienteFormScreen> {
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _salvando = false;
  bool get _editando => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    if (widget.cliente != null) {
      _nomeController.text = widget.cliente!.nome;
      _telefoneController.text = widget.cliente!.telefone ?? '';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final data = <String, dynamic>{
        'nome': _nomeController.text.trim(),
        if (_telefoneController.text.trim().isNotEmpty)
          'telefone': _telefoneController.text.trim(),
      };

      if (_editando) {
        await ref
            .read(clienteServiceProvider)
            .atualizar(widget.cliente!.id, data);
      } else {
        await ref.read(clienteServiceProvider).criar(data);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editando
              ? 'Cliente atualizado com sucesso'
              : 'Cliente cadastrado com sucesso'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toUserMessage('Erro ao salvar cliente')),
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Cliente' : 'Novo Cliente'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Form(
            key: _formKey,
            child: FormSectionCard(
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.person),

                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                ),
                TextFormField(
                  controller: _telefoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    prefixIcon: Icon(Icons.phone),

                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          SavingButton(
            label: _editando ? 'Atualizar Cliente' : 'Salvar Cliente',
            onPressed: _salvar,
            isSaving: _salvando,
            icon: Icons.save,
          ),
        ],
      ),
    );
  }
}
