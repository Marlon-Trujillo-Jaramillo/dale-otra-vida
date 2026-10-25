import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:intl/intl.dart';

String formatDistance(double km) {
  if (km < 0.5) {
    final meters = (km * 1000).round();
    final formatter = NumberFormat('#,##0', 'es_CO');
    return 'a ${formatter.format(meters)} m';
  }
  final formatter = NumberFormat('#,##0.0', 'es_CO');
  return 'a ${formatter.format(km)} km';
}

String formatCop(int value) {
  final formatter = NumberFormat('#,##0', 'es_CO');
  return '\$ ${formatter.format(value)}';
}

String formatDate(DateTime date) {
  return DateFormat('d MMM y', 'es').format(date.toLocal()).toLowerCase();
}

String conditionLabel(ItemCondition condition) {
  return switch (condition) {
    ItemCondition.asNew => 'Como nuevo',
    ItemCondition.good => 'Bueno',
    ItemCondition.used => 'Usado',
  };
}

String initialsFor(String? name) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty) return '?';
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
