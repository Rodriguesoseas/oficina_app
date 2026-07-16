import '../utils/parse.dart';

class Moto {
  const Moto({
    required this.id,
    required this.clienteId,
    required this.marca,
    required this.modelo,
    required this.placa,
    this.quilometragem,
    this.clienteNome,
  });

  final int id;
  final int clienteId;
  final String marca;
  final String modelo;
  final String placa;
  final int? quilometragem;
  final String? clienteNome;

  factory Moto.fromJson(Map<String, dynamic> json) {
    return Moto(
      id: json['id'] as int,
      clienteId: json['cliente_id'] as int,
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      placa: json['placa']?.toString() ?? '',
      quilometragem: parseInt(json['quilometragem']),
      clienteNome: json['cliente_nome']?.toString(),
    );
  }

  String get descricao => '$marca $modelo ($placa)';
}
