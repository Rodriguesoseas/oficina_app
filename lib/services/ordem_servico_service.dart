import '../core/api/api_client.dart';
import '../models/ordem_servico.dart';
import '../utils/parse.dart';

class OrdemServicoService {
  OrdemServicoService(this._client);

  final ApiClient _client;

  Future<List<OrdemServico>> listar({String? status, String? q}) {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (q != null) params['q'] = q;
    return _client.get<List<OrdemServico>>(
      '/ordem_servicos/recentes',
      queryParameters: params.isNotEmpty ? params : null,
      parser: (data) => parseList(data as List, OrdemServico.fromJson),
    );
  }

  Future<OrdemServico> detalhe(int id) {
    return _client.get<OrdemServico>(
      '/ordem_servicos/$id',
      parser: (data) => OrdemServico.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<OrdemServico> criar(Map<String, dynamic> data) {
    return _client.post<OrdemServico>(
      '/ordem_servicos',
      data: {'ordem_servico': data},
      parser: (json) => OrdemServico.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<OrdemServico> atualizar(int id, Map<String, dynamic> data) {
    return _client.patch<OrdemServico>(
      '/ordem_servicos/$id',
      data: {'ordem_servico': data},
      parser: (json) => OrdemServico.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<OrdemServico> alterarStatus(int id, String status) {
    return _client.patch<OrdemServico>(
      '/ordem_servicos/$id/status',
      data: {'status': status},
      parser: (json) => OrdemServico.fromJson(json as Map<String, dynamic>),
    );
  }
}
