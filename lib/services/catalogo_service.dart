import '../core/api/api_client.dart';
import '../models/item_estoque.dart';
import '../models/tipo_servico.dart';
import '../utils/parse.dart';

class CatalogoService {
  CatalogoService(this._client);

  final ApiClient _client;

  Future<List<TipoServico>> listarTiposServico() {
    return _client.get<List<TipoServico>>(
      '/tipo_servicos',
      parser: (data) => parseList(data as List, TipoServico.fromJson),
    );
  }

  Future<List<ItemEstoque>> listarItensEstoque() {
    return _client.get<List<ItemEstoque>>(
      '/item_estoques',
      parser: (data) => parseList(data as List, ItemEstoque.fromJson),
    );
  }

  Future<List<ItemEstoque>> listarItensEstoqueBaixo() {
    return _client.get<List<ItemEstoque>>(
      '/item_estoques',
      queryParameters: {'estoque_baixo': 'true'},
      parser: (data) => parseList(data as List, ItemEstoque.fromJson),
    );
  }

  Future<ItemEstoque> criarItemEstoque(Map<String, dynamic> data) {
    return _client.post<ItemEstoque>(
      '/item_estoques',
      data: {'item_estoque': data},
      parser: (json) => ItemEstoque.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ItemEstoque> atualizarItemEstoque(int id, Map<String, dynamic> data) {
    return _client.patch<ItemEstoque>(
      '/item_estoques/$id',
      data: {'item_estoque': data},
      parser: (json) => ItemEstoque.fromJson(json as Map<String, dynamic>),
    );
  }
}
