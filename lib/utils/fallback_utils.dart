String fallbackIfEmpty(dynamic value, [String fallback = 'N/A']) {
  if (value == null) return fallback;
  final str = value.toString().trim();
  return str.isEmpty ? fallback : str;
}
