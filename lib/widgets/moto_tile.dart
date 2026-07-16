import 'package:flutter/material.dart';

import '../models/moto.dart';

class MotoTile extends StatelessWidget {
  const MotoTile({
    super.key,
    required this.moto,
    required this.onTap,
  });

  final Moto moto;
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
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Icon(Icons.two_wheeler, color: theme.colorScheme.secondary),
          ),
          title: Text(moto.descricao),
          subtitle: Text(moto.clienteNome ?? 'Cliente #${moto.clienteId}'),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
