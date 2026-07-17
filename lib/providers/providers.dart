import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../models/agenda_evento.dart';
import '../models/cliente.dart';
import '../models/dashboard_data.dart';
import '../models/item_estoque.dart';
import '../models/moto.dart';
import '../models/ordem_servico.dart';
import '../services/agenda_service.dart';
import '../services/atendimento_service.dart';
import '../services/auth_service.dart';
import '../services/catalogo_service.dart';
import '../services/cliente_service.dart';
import '../services/dashboard_service.dart';
import '../services/moto_service.dart';
import '../services/ordem_servico_service.dart';
import 'auth_provider.dart';


final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(apiClientProvider)),
);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authServiceProvider),
    ref.watch(apiClientProvider),
  );
});

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

final atendimentoServiceProvider = Provider<AtendimentoService>(
  (ref) => AtendimentoService(ref.watch(apiClientProvider)),
);

final motoDetailProvider = FutureProvider.family<Moto, int>((ref, id) async {
  return ref.read(motoServiceProvider).detalhe(id);
});

final agendaServiceProvider = Provider<AgendaService>(
  (ref) => AgendaService(ref.watch(apiClientProvider)),
);

final agendaProvider = FutureProvider<List<AgendaEvento>>((ref) async {
  return ref.read(agendaServiceProvider).listar();
});

final catalogoServiceProvider = Provider<CatalogoService>(
  (ref) => CatalogoService(ref.watch(apiClientProvider)),
);

final itensEstoqueProvider = FutureProvider<List<ItemEstoque>>((ref) async {
  return ref.read(catalogoServiceProvider).listarItensEstoque();
});

final itemEstoqueDetailProvider =
    FutureProvider.family<ItemEstoque, int>((ref, id) async {
  return ref.read(catalogoServiceProvider).detalheItemEstoque(id);
});

final dashboardServiceProvider = Provider<DashboardService>(
  (ref) => DashboardService(ref.watch(apiClientProvider)),
);

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  return ref.read(dashboardServiceProvider).carregar();
});

final ordemServicoServiceProvider = Provider<OrdemServicoService>(
  (ref) => OrdemServicoService(ref.watch(apiClientProvider)),
);

final ordensServicoProvider = FutureProvider<List<OrdemServico>>((ref) async {
  return ref.read(ordemServicoServiceProvider).listar();
});

final ordemServicoDetailProvider =
    FutureProvider.family<OrdemServico, int>((ref, id) async {
  return ref.read(ordemServicoServiceProvider).detalhe(id);
});

final darkModeProvider = StateProvider<bool>((ref) => false);
