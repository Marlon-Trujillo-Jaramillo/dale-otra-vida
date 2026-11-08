const _months = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// "12 nov" in Colombia's time (UTC−5, no daylight saving), for texts the
/// server writes into notifications and chat messages.
String shortDateCo(DateTime date) {
  final local = date.toUtc().subtract(const Duration(hours: 5));
  return '${local.day} ${_months[local.month - 1]}';
}

/// Whole days [date] is overdue at [now], 0 while not overdue.
int daysOverdue(DateTime date, DateTime now) {
  final late = now.toUtc().difference(date.toUtc());
  return late.isNegative ? 0 : late.inDays + 1;
}
