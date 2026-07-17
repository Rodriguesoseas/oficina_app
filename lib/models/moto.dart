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
    this.ano,
    this.urlFoto,
    this.proximaRevisaoKm,
    this.timeline = const [],
  });

  final int id;
  final int clienteId;
  final String marca;
  final String modelo;
  final String placa;
  final int? quilometragem;
  final String? clienteNome;
  final int? ano;
  final String? urlFoto;
  final int? proximaRevisaoKm;
  final List<TimelineEvent> timeline;

  factory Moto.fromJson(Map<String, dynamic> json) {
    final timelineJson = json['timeline'];
    return Moto(
      id: parseInt(json['id']) ?? 0,
      clienteId: parseInt(json['cliente_id']) ?? 0,
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      placa: json['placa']?.toString() ?? '',
      quilometragem: parseInt(json['quilometragem']),
      clienteNome: json['cliente_nome']?.toString(),
      ano: parseInt(json['ano']),
      urlFoto: json['url_foto']?.toString(),
      proximaRevisaoKm: parseInt(json['proxima_revisao_km']),
      timeline: timelineJson is List
          ? timelineJson.whereType<Map<String, dynamic>>().map(TimelineEvent.fromJson).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'marca': marca,
        'modelo': modelo,
        'placa': placa,
        'cliente_id': clienteId,
        if (quilometragem != null) 'quilometragem': quilometragem,
      };

  String get descricao => '$marca $modelo ($placa)';
}

class TimelineEvent {
  const TimelineEvent({
    required this.tipo,
    required this.titulo,
    this.data,
    this.descricao,
    this.km,
    this.valor,
  });

  final String tipo;
  final String titulo;
  final DateTime? data;
  final String? descricao;
  final int? km;
  final double? valor;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      tipo: json['tipo']?.toString() ?? 'servico',
      titulo: json['titulo']?.toString() ?? '',
      data: parseDateTime(json['data']),
      descricao: json['descricao']?.toString(),
      km: parseInt(json['km']),
      valor: json['valor'] != null ? parseDouble(json['valor']) : null,
    );
  }
}
