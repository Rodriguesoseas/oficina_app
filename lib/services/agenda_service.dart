import '../core/api/api_client.dart';
import '../models/agenda_evento.dart';
import '../utils/parse.dart';

class AgendaService {
  AgendaService(this._client);

  final ApiClient _client;

  Future<List<AgendaEvento>> listar({String? data}) {
    return _client.get<List<AgendaEvento>>(
      '/ordem_servicos/prazos',
      queryParameters: data != null ? {'data': data} : null,
      parser: (data) => parseList(data as List, AgendaEvento.fromJson),
    );
  }
}
