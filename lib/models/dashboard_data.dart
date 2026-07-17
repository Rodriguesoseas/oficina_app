import '../utils/parse.dart';
import 'ordem_servico.dart';

class DashboardData {
  const DashboardData({
    this.motosNaOficina = 0,
    this.entregasHoje = 0,
    this.itensEstoqueBaixo = 0,
    this.faturamentoDia = 0,
    this.ultimasOS = const [],
  });

  final int motosNaOficina;
  final int entregasHoje;
  final int itensEstoqueBaixo;
  final double faturamentoDia;
  final List<OrdemServico> ultimasOS;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final osJson = json['ultimas_os'];
    return DashboardData(
      motosNaOficina: parseInt(json['motos_na_oficina']) ?? 0,
      entregasHoje: parseInt(json['entregas_hoje']) ?? 0,
      itensEstoqueBaixo: parseInt(json['itens_estoque_baixo']) ?? 0,
      faturamentoDia: parseDouble(json['faturamento_dia']),
      ultimasOS: osJson is List
          ? osJson.whereType<Map<String, dynamic>>().map(OrdemServico.fromJson).toList()
          : const [],
    );
  }
}
