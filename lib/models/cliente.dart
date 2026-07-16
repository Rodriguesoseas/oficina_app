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
      id: json['id'] as int,
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
}

class MotoResumo {
  const MotoResumo({
    required this.id,
    required this.clienteId,
    required this.marca,
    required this.modelo,
    required this.placa,
    this.quilometragem,
  });

  final int id;
  final int clienteId;
  final String marca;
  final String modelo;
  final String placa;
  final int? quilometragem;

  factory MotoResumo.fromJson(Map<String, dynamic> json) {
    return MotoResumo(
      id: json['id'] as int,
      clienteId: json['cliente_id'] as int,
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      placa: json['placa']?.toString() ?? '',
      quilometragem: parseInt(json['quilometragem']),
    );
  }

  String get descricao => '$marca $modelo ($placa)';
}
