import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../models/cliente.dart';
import '../models/item_estoque.dart';
import '../models/ordem_servico.dart';
import '../services/atendimento_service.dart';
import '../services/catalogo_service.dart';
import '../services/cliente_service.dart';
import '../services/moto_service.dart';
import '../services/ordem_servico_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final clienteServiceProvider = Provider<ClienteService>(
  (ref) => ClienteService(ref.watch(apiClientProvider)),
);

final clientesListProvider = FutureProvider<List<Cliente>>((ref) async {
  return ref.read(clienteServiceProvider).listarTodos();
});

final clienteDetailProvider =
    FutureProvider.family<Cliente, int>((ref, id) async {
  return ref.read(clienteServiceProvider).detalhe(id);
});

final motoServiceProvider = Provider<MotoService>(
  (ref) => MotoService(ref.watch(apiClientProvider)),
);

final catalogoServiceProvider = Provider<CatalogoService>(
  (ref) => CatalogoService(ref.watch(apiClientProvider)),
);

final itensEstoqueProvider = FutureProvider<List<ItemEstoque>>((ref) async {
  return ref.read(catalogoServiceProvider).listarItensEstoque();
});

final atendimentoServiceProvider = Provider<AtendimentoService>(
  (ref) => AtendimentoService(ref.watch(apiClientProvider)),
);

final ordemServiceProvider = Provider<OrdemServicoService>(
  (ref) => OrdemServicoService(ref.watch(apiClientProvider)),
);

final ordemDetailProvider =
    FutureProvider.family<OrdemServico, int>((ref, id) async {
  return ref.read(ordemServiceProvider).detalhe(id);
});

final darkModeProvider = StateProvider<bool>((ref) => false);
