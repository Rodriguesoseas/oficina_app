import '../core/api/api_client.dart';
import '../models/moto.dart';
import '../utils/parse.dart';

class MotoService {
  MotoService(this._client);

  final ApiClient _client;

  Future<List<Moto>> buscarPorPlaca(String placa) {
    return _client.get<List<Moto>>(
      '/motos/busca',
      queryParameters: {'placa': placa},
      parser: (data) => parseList(data as List, Moto.fromJson),
    );
  }

  Future<Moto> criar(int clienteId, Map<String, dynamic> data) {
    data['cliente_id'] = clienteId;
    return _client.post<Moto>(
      '/motos',
      data: {'moto': data},
      parser: (json) => Moto.fromJson(json as Map<String, dynamic>),
    );
  }
}
