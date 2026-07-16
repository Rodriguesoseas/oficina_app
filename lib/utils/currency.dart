import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

String formatCurrency(double value) => _currencyFormat.format(value);

String formatDateTime(DateTime? date) {
  if (date == null) return '-';
  return DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
}
