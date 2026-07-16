import '../utils/parse.dart';

class TipoServico {
  const TipoServico({
    required this.id,
    required this.nome,
    required this.valorMaoObraPadrao,
    required this.ativo,
    required this.ordem,
  });

  final int id;
  final String nome;
  final double valorMaoObraPadrao;
  final bool ativo;
  final int ordem;

  factory TipoServico.fromJson(Map<String, dynamic> json) {
    return TipoServico(
      id: json['id'] as int,
      nome: json['nome']?.toString() ?? '',
      valorMaoObraPadrao: parseDouble(json['valor_mao_obra_padrao']),
      ativo: json['ativo'] == true,
      ordem: json['ordem'] as int? ?? 0,
    );
  }
}
