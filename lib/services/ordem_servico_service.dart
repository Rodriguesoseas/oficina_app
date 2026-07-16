import '../core/api/api_client.dart';
import '../models/ordem_servico.dart';
import '../utils/parse.dart';

class OrdemServicoService {
  OrdemServicoService(this._client);

  final ApiClient _client;

  Future<List<OrdemServico>> recentes() {
    return _client.get<List<OrdemServico>>(
      '/ordem_servicos/recentes',
      parser: (data) => parseList(data as List, OrdemServico.fromJson),
    );
  }

  Future<OrdemServico> detalhe(int id) {
    return _client.get<OrdemServico>(
      '/ordem_servicos/$id',
      parser: (data) => OrdemServico.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> excluir(int id) {
    return _client.delete('/ordem_servicos/$id');
  }
}
