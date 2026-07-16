int? parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

List<T> parseList<T>(List data, T Function(Map<String, dynamic>) fromJson) {
  return data.whereType<Map<String, dynamic>>().map(fromJson).toList();
}
