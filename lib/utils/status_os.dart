import 'package:flutter/material.dart';

Color statusOsColor(String status, {bool atrasada = false}) {
  if (atrasada) return Colors.red;
  switch (status) {
    case 'aberta':
      return Colors.blue;
    case 'finalizada':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

String statusOsLabel(String status) {
  switch (status) {
    case 'aberta':
      return 'Aberta';
    case 'finalizada':
      return 'Finalizada';
    default:
      return status;
  }
}
