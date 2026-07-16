import '../core/api/api_client.dart';
import '../models/ordem_servico.dart';

class AtendimentoService {
  AtendimentoService(this._client);

  final ApiClient _client;

  Future<OrdemServico> criarRapido(Map<String, dynamic> payload) {
    return _client.post<OrdemServico>(
      '/atendimentos/rapido',
      data: payload,
      parser: (data) => OrdemServico.fromJson(data as Map<String, dynamic>),
    );
  }
}
