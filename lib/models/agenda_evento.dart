import '../utils/parse.dart';

class AgendaEvento {
  const AgendaEvento({
    required this.id,
    required this.titulo,
    required this.tipo,
    this.dataInicio,
    this.dataFim,
    this.descricao,
    this.idReferencia,
    this.status,
  });

  final int id;
  final String titulo;
  final String tipo;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final String? descricao;
  final int? idReferencia;
  final String? status;

  bool get isEntrega => tipo == 'entrega';
  bool get isAgendamento => tipo == 'agendamento';
  bool get isRevisao => tipo == 'revisao';
  bool get isAberta => status == 'aberta';
  bool get isFinalizada => status == 'finalizada';

  factory AgendaEvento.fromJson(Map<String, dynamic> json) {
    return AgendaEvento(
      id: parseInt(json['id']) ?? 0,
      titulo: json['titulo']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? 'agendamento',
      dataInicio: parseDateTime(json['data_inicio']),
      dataFim: parseDateTime(json['data_fim']),
      descricao: json['descricao']?.toString(),
      idReferencia: parseInt(json['id_referencia']),
      status: json['status']?.toString(),
    );
  }
}
