import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../utils/extensions.dart';
import '../widgets/form_section_card.dart';

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
  final _formKey = GlobalKey<FormState>();
  bool _salvando = false;

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _quilometragemController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final data = <String, dynamic>{
        'marca': _marcaController.text.trim(),
        'modelo': _modeloController.text.trim(),
        'placa': _placaController.text.trim(),
      };

      final km = _quilometragemController.text.trim();
      if (km.isNotEmpty) {
        data['quilometragem'] = int.tryParse(km);
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
        padding: const EdgeInsets.all(16),
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
                    border: OutlineInputBorder(),
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
                    border: OutlineInputBorder(),
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
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                TextFormField(
                  controller: _quilometragemController,
                  decoration: const InputDecoration(
                    labelText: 'Quilometragem',
                    prefixIcon: Icon(Icons.speed),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
            label: const Text('Salvar Moto'),
          ),
        ],
      ),
    );
  }
}
