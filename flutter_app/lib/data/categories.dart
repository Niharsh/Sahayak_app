const CATEGORY_LABELS = ['Maid', 'Plumber', 'Electrician', 'Painter', 'Gardener', 'Barber'];

String valueForLabel(String label) => label.trim().toLowerCase();
String labelForValue(String value) {
  final v = value.trim().toLowerCase();
  final idx = CATEGORY_LABELS.indexWhere((l) => l.toLowerCase() == v);
  if (idx >= 0) return CATEGORY_LABELS[idx];
  // fallback: capitalize
  if (value.isEmpty) return '';
  return value[0].toUpperCase() + value.substring(1);
}
