import '../utils/parse.dart';

class OrdemServico {
  const OrdemServico({
    required this.id,
    required this.clienteId,
    required this.clienteNome,
    this.clienteTelefone,
    required this.motoId,
    this.motoDescricao,
    this.motoPlaca,
    required this.status,
    this.problema,
    this.diagnostico,
    this.servicos = const [],
    this.pecas = const [],
    this.prazo,
    this.valorServicos = 0,
    this.valorPecas = 0,
    this.valorTotal = 0,
    this.dataEntrada,
    this.dataSaida,
    this.mecanico,
    this.mecanicoId,
    this.mecanicoNome,
    this.observacoes,
    this.checklist = const [],
  });

  final int id;
  final int clienteId;
  final String clienteNome;
  final String? clienteTelefone;
  final int motoId;
  final String? motoDescricao;
  final String? motoPlaca;
  final String status;
  final String? problema;
  final String? diagnostico;
  final List<ServicoItem> servicos;
  final List<PecaItem> pecas;
  final DateTime? prazo;
  final double valorServicos;
  final double valorPecas;
  final double valorTotal;
  final DateTime? dataEntrada;
  final DateTime? dataSaida;
  final String? mecanico;
  final int? mecanicoId;
  final String? mecanicoNome;
  final String? observacoes;
  final List<String> checklist;

  bool get isAberta => status == 'aberta';
  bool get isFinalizada => status == 'finalizada';
  bool get isAtrasada =>
      prazo != null && prazo!.isBefore(DateTime.now()) && !isFinalizada;

  factory OrdemServico.fromJson(Map<String, dynamic> json) {
    final servicosJson = json['servicos'];
    final pecasJson = json['pecas'];
    final checklistJson = json['checklist'];

    return OrdemServico(
      id: parseInt(json['id']) ?? 0,
      clienteId: parseInt(json['cliente_id']) ?? 0,
      clienteNome: json['cliente_nome']?.toString() ?? '',
      clienteTelefone: json['cliente_telefone']?.toString(),
      motoId: parseInt(json['moto_id']) ?? 0,
      motoDescricao: json['moto_descricao']?.toString(),
      motoPlaca: json['moto_placa']?.toString(),
      status: json['status']?.toString() ?? 'aberta',
      problema: json['problema']?.toString(),
      diagnostico: json['diagnostico']?.toString(),
      servicos: servicosJson is List
          ? servicosJson.whereType<Map<String, dynamic>>().map(ServicoItem.fromJson).toList()
          : const [],
      pecas: pecasJson is List
          ? pecasJson.whereType<Map<String, dynamic>>().map(PecaItem.fromJson).toList()
          : const [],
      prazo: parseDateTime(json['prazo']),
      valorServicos: parseDouble(json['valor_servicos']),
      valorPecas: parseDouble(json['valor_pecas']),
      valorTotal: parseDouble(json['valor_total']),
      dataEntrada: parseDateTime(json['data_entrada']),
      dataSaida: parseDateTime(json['data_saida']),
      mecanico: json['mecanico']?.toString(),
      mecanicoId: json['mecanico_id'] as int?,
      mecanicoNome: json['mecanico_nome']?.toString(),
      observacoes: json['observacao']?.toString(),
      checklist: checklistJson is List
          ? checklistJson.whereType<String>().toList()
          : const [],
    );
  }
}

class ServicoItem {
  const ServicoItem({
    this.id,
    required this.nome,
    this.quantidade = 1,
    this.valorUnitario = 0,
  });

  final int? id;
  final String nome;
  final int quantidade;
  final double valorUnitario;

  double get valorTotal => quantidade * valorUnitario;

  factory ServicoItem.fromJson(Map<String, dynamic> json) {
    return ServicoItem(
      id: parseInt(json['id']),
      nome: json['nome']?.toString() ?? '',
      quantidade: parseInt(json['quantidade']) ?? 1,
      valorUnitario: parseDouble(json['valor_unitario']),
    );
  }
}

class PecaItem {
  const PecaItem({
    this.id,
    required this.nome,
    this.quantidade = 1,
    this.valorUnitario = 0,
  });

  final int? id;
  final String nome;
  final int quantidade;
  final double valorUnitario;

  double get valorTotal => quantidade * valorUnitario;

  factory PecaItem.fromJson(Map<String, dynamic> json) {
    return PecaItem(
      id: parseInt(json['id']),
      nome: json['nome']?.toString() ?? '',
      quantidade: parseInt(json['quantidade']) ?? 1,
      valorUnitario: parseDouble(json['valor_unitario']),
    );
  }
}
