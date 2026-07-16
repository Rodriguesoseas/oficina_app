import '../core/api/api_client.dart';
import '../models/cliente.dart';
import '../utils/parse.dart';

class ClienteService {
  ClienteService(this._client);

  final ApiClient _client;

  Future<List<Cliente>> buscar(String query) {
    return _client.get<List<Cliente>>(
      '/clientes',
      queryParameters: {'q': query},
      parser: (data) => parseList(data as List, Cliente.fromJson),
    );
  }

  Future<Cliente> detalhe(int id) {
    return _client.get<Cliente>(
      '/clientes/$id',
      parser: (data) => Cliente.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<Cliente>> listarTodos() {
    return _client.get<List<Cliente>>(
      '/clientes',
      parser: (data) => parseList(data as List, Cliente.fromJson),
    );
  }

  Future<Cliente> criar(Map<String, dynamic> data) {
    return _client.post<Cliente>(
      '/clientes',
      data: {'cliente': data},
      parser: (json) => Cliente.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Cliente> atualizar(int id, Map<String, dynamic> data) {
    return _client.patch<Cliente>(
      '/clientes/$id',
      data: {'cliente': data},
      parser: (json) => Cliente.fromJson(json as Map<String, dynamic>),
    );
  }
}
