import 'package:flutter/material.dart';

import '../utils/parse.dart';

class ItemEstoque {
  const ItemEstoque({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.quantidade,
    required this.estoqueMinimo,
    required this.precoUnitario,
    required this.ativo,
    required this.estoqueBaixo,
  });

  final int id;
  final String nome;
  final String categoria;
  final int quantidade;
  final int estoqueMinimo;
  final double precoUnitario;
  final bool ativo;
  final bool estoqueBaixo;

  double get progressoNormalizado {
    if (estoqueMinimo <= 0) return 1.0;
    return (quantidade / (estoqueMinimo * 4)).clamp(0.0, 1.0);
  }

  Color get estoqueCor => estoqueBaixo
      ? Colors.red
      : (quantidade < estoqueMinimo * 2 ? Colors.orange : Colors.green);

  factory ItemEstoque.fromJson(Map<String, dynamic> json) {
    return ItemEstoque(
      id: json['id'] as int,
      nome: json['nome']?.toString() ?? '',
      categoria: json['categoria']?.toString() ?? '',
      quantidade: parseInt(json['quantidade']) ?? 0,
      estoqueMinimo: parseInt(json['estoque_minimo']) ?? 0,
      precoUnitario: parseDouble(json['preco_unitario']),
      ativo: json['ativo'] == true,
      estoqueBaixo: json['estoque_baixo'] == true,
    );
  }

  ItemEstoque copyWith({
    int? id,
    String? nome,
    String? categoria,
    int? quantidade,
    int? estoqueMinimo,
    double? precoUnitario,
    bool? ativo,
    bool? estoqueBaixo,
  }) {
    return ItemEstoque(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      quantidade: quantidade ?? this.quantidade,
      estoqueMinimo: estoqueMinimo ?? this.estoqueMinimo,
      precoUnitario: precoUnitario ?? this.precoUnitario,
      ativo: ativo ?? this.ativo,
      estoqueBaixo: estoqueBaixo ?? this.estoqueBaixo,
    );
  }
}
