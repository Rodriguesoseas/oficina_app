import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/agenda_evento.dart';
import '../providers/providers.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventosAsync = ref.watch(agendaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(AppSpacing.lg),
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (date) => setState(() => _selectedDate = date),
            ),
          ),
          Expanded(
            child: eventosAsync.when(
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorDisplay(
                message: error.toUserMessage('Erro ao carregar agenda'),
              ),
              data: (eventos) {
                final eventosDia = eventos.where((e) {
                  if (e.dataInicio == null) return false;
                  return e.dataInicio!.year == _selectedDate.year &&
                      e.dataInicio!.month == _selectedDate.month &&
                      e.dataInicio!.day == _selectedDate.day;
                }).toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                  children: [
                    Text(
                      'Eventos do dia ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (eventosDia.isEmpty)
                      const EmptyState(
                        icon: Icons.event_busy,
                        title: 'Nenhum evento neste dia',
                      )
                    else
                      ...eventosDia.map((e) => _EventoCard(evento: e)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventoCard extends StatelessWidget {
  const _EventoCard({required this.evento});

  final AgendaEvento evento;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cor = _corTipo(theme);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cor.withValues(alpha: 0.12),
              child: Icon(_iconeTipo(), color: cor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(evento.titulo, style: theme.textTheme.titleSmall),
                  if (evento.descricao != null)
                    Text(
                      evento.descricao!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (evento.dataInicio != null)
                    Text(
                      '${evento.dataInicio!.hour.toString().padLeft(2, '0')}:${evento.dataInicio!.minute.toString().padLeft(2, '0')}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            Chip(
              label: Text(_labelTipo(), style: TextStyle(fontSize: 11, color: cor)),
              visualDensity: VisualDensity.compact,
              backgroundColor: cor.withValues(alpha: 0.12),
              side: BorderSide.none,
            ),
          ],
        ),
      ),
    );
  }

  Color _corTipo(ThemeData theme) {
    if (evento.isEntrega && evento.isFinalizada) return Colors.green;
    if (evento.isEntrega && evento.isAberta) return theme.colorScheme.primary;
    if (evento.isAgendamento) return theme.colorScheme.primary;
    if (evento.isRevisao) return Colors.orange;
    return theme.colorScheme.secondary;
  }

  IconData _iconeTipo() {
    if (evento.isEntrega && evento.isFinalizada) return Icons.check_circle;
    if (evento.isEntrega && evento.isAberta) return Icons.build_circle;
    if (evento.isAgendamento) return Icons.event;
    if (evento.isRevisao) return Icons.build_circle;
    return Icons.event_note;
  }

  String _labelTipo() {
    if (evento.isEntrega && evento.isFinalizada) return 'Entregue';
    if (evento.isEntrega && evento.isAberta) return 'Em produção';
    if (evento.isAgendamento) return 'Agendado';
    if (evento.isRevisao) return 'Revisão';
    return 'Evento';
  }
}
