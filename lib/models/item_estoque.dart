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
    this.descricao,
  });

  final int id;
  final String nome;
  final String categoria;
  final int quantidade;
  final int estoqueMinimo;
  final double precoUnitario;
  final bool ativo;
  final bool estoqueBaixo;
  final String? descricao;

  double get progressoNormalizado {
    if (estoqueMinimo <= 0) return 1.0;
    return (quantidade / (estoqueMinimo * 4)).clamp(0.0, 1.0);
  }

  factory ItemEstoque.fromJson(Map<String, dynamic> json) {
    return ItemEstoque(
      id: parseInt(json['id']) ?? 0,
      nome: json['nome']?.toString() ?? '',
      categoria: json['categoria']?.toString() ?? '',
      quantidade: parseInt(json['quantidade']) ?? 0,
      estoqueMinimo: parseInt(json['estoque_minimo']) ?? 0,
      precoUnitario: parseDouble(json['preco_unitario']),
      ativo: json['ativo'] == true,
      estoqueBaixo: json['estoque_baixo'] == true,
      descricao: json['descricao']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'categoria': categoria,
        'quantidade': quantidade,
        'estoque_minimo': estoqueMinimo,
        'preco_unitario': precoUnitario,
        'ativo': ativo,
        if (descricao != null) 'descricao': descricao,
      };

  ItemEstoque copyWith({
    int? id,
    String? nome,
    String? categoria,
    int? quantidade,
    int? estoqueMinimo,
    double? precoUnitario,
    bool? ativo,
    bool? estoqueBaixo,
    String? descricao,
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
      descricao: descricao ?? this.descricao,
    );
  }
}
