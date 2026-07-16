import 'package:flutter/material.dart';

import '../models/cliente.dart';

class ClienteTile extends StatelessWidget {
  const ClienteTile({
    super.key,
    required this.cliente,
    required this.onTap,
  });

  final Cliente cliente;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(Icons.person, color: theme.colorScheme.primary),
          ),
          title: Text(cliente.nome),
          subtitle: Text(cliente.telefone ?? 'Sem telefone'),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
