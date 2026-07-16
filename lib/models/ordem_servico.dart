import '../utils/parse.dart';
import 'cliente.dart';
import 'item_estoque.dart';
import 'moto.dart';
import 'tipo_servico.dart';

class OrdemServico {
  const OrdemServico({
    required this.id,
    this.clienteId,
    this.motoId,
    required this.tipoServicoId,
    required this.status,
    required this.valorPecas,
    required this.valorMaoObra,
    required this.valorTotal,
    this.quilometragem,
    this.observacao,
    this.avulso = false,
    this.avulsoNome,
    this.avulsoTelefone,
    this.avulsoMotoDescricao,
    this.createdAt,
    this.cliente,
    this.moto,
    this.tipoServico,
    this.itens = const [],
  });

  final int id;
  final int? clienteId;
  final int? motoId;
  final int tipoServicoId;
  final String status;
  final double valorPecas;
  final double valorMaoObra;
  final double valorTotal;
  final int? quilometragem;
  final String? observacao;
  final bool avulso;
  final String? avulsoNome;
  final String? avulsoTelefone;
  final String? avulsoMotoDescricao;
  final DateTime? createdAt;
  final Cliente? cliente;
  final Moto? moto;
  final TipoServico? tipoServico;
  final List<ItemOrdemServico> itens;

  factory OrdemServico.fromJson(Map<String, dynamic> json) {
    final itensJson = json['item_ordem_servicos'];
    return OrdemServico(
      id: json['id'] as int,
      clienteId: parseInt(json['cliente_id']),
      motoId: parseInt(json['moto_id']),
      tipoServicoId: json['tipo_servico_id'] as int,
      status: json['status']?.toString() ?? '',
      valorPecas: parseDouble(json['valor_pecas']),
      valorMaoObra: parseDouble(json['valor_mao_obra']),
      valorTotal: parseDouble(json['valor_total']),
      quilometragem: parseInt(json['quilometragem']),
      observacao: json['observacao']?.toString(),
      avulso: json['avulso'] == true,
      avulsoNome: json['avulso_nome']?.toString(),
      avulsoTelefone: json['avulso_telefone']?.toString(),
      avulsoMotoDescricao: json['avulso_moto_descricao']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      cliente: json['cliente'] is Map<String, dynamic>
          ? Cliente.fromJson(json['cliente'] as Map<String, dynamic>)
          : null,
      moto: json['moto'] is Map<String, dynamic>
          ? Moto.fromJson(json['moto'] as Map<String, dynamic>)
          : null,
      tipoServico: json['tipo_servico'] is Map<String, dynamic>
          ? TipoServico.fromJson(json['tipo_servico'] as Map<String, dynamic>)
          : null,
      itens: itensJson is List
          ? itensJson
              .whereType<Map<String, dynamic>>()
              .map(ItemOrdemServico.fromJson)
              .toList()
          : const [],
    );
  }

  String get tituloCliente {
    if (avulso) {
      return avulsoNome ?? 'Atendimento avulso';
    }
    return cliente?.nome ?? 'Cliente não informado';
  }

  String get tituloMoto {
    if (avulso) {
      return avulsoMotoDescricao ?? 'Moto não informada';
    }
    return moto?.descricao ?? 'Moto não informada';
  }
}

class ItemOrdemServico {
  const ItemOrdemServico({
    required this.id,
    required this.itemEstoqueId,
    required this.quantidade,
    required this.precoUnitario,
    required this.subtotal,
    this.itemEstoque,
  });

  final int id;
  final int itemEstoqueId;
  final int quantidade;
  final double precoUnitario;
  final double subtotal;
  final ItemEstoque? itemEstoque;

  factory ItemOrdemServico.fromJson(Map<String, dynamic> json) {
    return ItemOrdemServico(
      id: json['id'] as int,
      itemEstoqueId: json['item_estoque_id'] as int,
      quantidade: parseInt(json['quantidade']) ?? 0,
      precoUnitario: parseDouble(json['preco_unitario']),
      subtotal: parseDouble(json['subtotal']),
      itemEstoque: json['item_estoque'] is Map<String, dynamic>
          ? ItemEstoque.fromJson(json['item_estoque'] as Map<String, dynamic>)
          : null,
    );
  }
}
