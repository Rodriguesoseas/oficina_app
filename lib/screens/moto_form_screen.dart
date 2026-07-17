import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../utils/extensions.dart';
import '../theme/app_spacing.dart';
import '../widgets/form_section_card.dart';
import '../widgets/saving_button.dart';

class MotoFormScreen extends ConsumerStatefulWidget {
  const MotoFormScreen({
    super.key,
    required this.clienteId,
  });

  final int clienteId;

  @override
  ConsumerState<MotoFormScreen> createState() => _MotoFormScreenState();
}

class _MotoFormScreenState extends ConsumerState<MotoFormScreen> {
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _placaController = TextEditingController();
  final _quilometragemController = TextEditingController();
  final _anoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _salvando = false;

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _quilometragemController.dispose();
    _anoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final data = <String, dynamic>{
        'marca': _marcaController.text.trim(),
        'modelo': _modeloController.text.trim(),
        'placa': _placaController.text.trim(),
      };

      final km = _quilometragemController.text.trim();
      if (km.isNotEmpty) {
        final sanitizado = km.replaceAll('.', '').replaceAll(',', '');
        final parsed = int.tryParse(sanitizado);
        if (parsed != null) {
          data['quilometragem'] = parsed;
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quilometragem inválida')),
          );
          return;
        }
      }

      final ano = _anoController.text.trim();
      if (ano.isNotEmpty) {
        final parsed = int.tryParse(ano);
        if (parsed != null) {
          data['ano'] = parsed;
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ano inválido')),
          );
          return;
        }
      }

      final moto = await ref
          .read(motoServiceProvider)
          .criar(widget.clienteId, data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Moto cadastrada com sucesso')),
      );
      Navigator.of(context).pop(moto);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toUserMessage('Erro ao cadastrar moto')),
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Moto')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Form(
            key: _formKey,
            child: FormSectionCard(
              children: [
                TextFormField(
                  controller: _marcaController,
                  decoration: const InputDecoration(
                    labelText: 'Marca',
                    prefixIcon: Icon(Icons.directions_car),

                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe a marca' : null,
                ),
                TextFormField(
                  controller: _modeloController,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    prefixIcon: Icon(Icons.build),

                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe o modelo' : null,
                ),
                TextFormField(
                  controller: _placaController,
                  decoration: const InputDecoration(
                    labelText: 'Placa',
                    prefixIcon: Icon(Icons.tag),

                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                TextFormField(
                  controller: _quilometragemController,
                  decoration: const InputDecoration(
                    labelText: 'Quilometragem',
                    prefixIcon: Icon(Icons.speed),

                  ),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _anoController,
                  decoration: const InputDecoration(
                    labelText: 'Ano',
                    prefixIcon: Icon(Icons.calendar_today),

                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          SavingButton(
            label: 'Salvar Moto',
            onPressed: _salvar,
            isSaving: _salvando,
            icon: Icons.save,
          ),
        ],
      ),
    );
  }
}
