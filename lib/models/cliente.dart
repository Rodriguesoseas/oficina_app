import '../utils/parse.dart';

class Cliente {
  const Cliente({
    required this.id,
    required this.nome,
    this.telefone,
    this.motos = const [],
  });

  final int id;
  final String nome;
  final String? telefone;
  final List<MotoResumo> motos;

  factory Cliente.fromJson(Map<String, dynamic> json) {
    final motosJson = json['motos'];
    return Cliente(
      id: parseInt(json['id']) ?? 0,
      nome: json['nome']?.toString() ?? '',
      telefone: json['telefone']?.toString(),
      motos: motosJson is List
          ? motosJson
              .whereType<Map<String, dynamic>>()
              .map(MotoResumo.fromJson)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        if (telefone != null) 'telefone': telefone,
      };
}

class MotoResumo {
  const MotoResumo({
    required this.id,
    required this.clienteId,
    required this.marca,
    required this.modelo,
    required this.placa,
    this.quilometragem,
    this.ano,
  });

  final int id;
  final int clienteId;
  final String marca;
  final String modelo;
  final String placa;
  final int? quilometragem;
  final int? ano;

  factory MotoResumo.fromJson(Map<String, dynamic> json) {
    return MotoResumo(
      id: parseInt(json['id']) ?? 0,
      clienteId: parseInt(json['cliente_id']) ?? 0,
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      placa: json['placa']?.toString() ?? '',
      quilometragem: parseInt(json['quilometragem']),
      ano: parseInt(json['ano']),
    );
  }

  String get descricao {
    if (ano != null) return '$marca $modelo $ano ($placa)';
    return '$marca $modelo ($placa)';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cliente_id': clienteId,
        'marca': marca,
        'modelo': modelo,
        'placa': placa,
        if (quilometragem != null) 'quilometragem': quilometragem,
        if (ano != null) 'ano': ano,
      };
}
