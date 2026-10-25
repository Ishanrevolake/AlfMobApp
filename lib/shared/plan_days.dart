const weekDays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// The next Monday, including [date] itself when it is a Monday.
DateTime nextPlanMonday(DateTime date) => DateTime(
  date.year,
  date.month,
  date.day + (DateTime.monday - date.weekday + 7) % 7,
);

String fullPlanDay(String value) {
  final label = value.trim();
  for (var i = 0; i < weekDays.length; i++) {
    final day = weekDays[i];
    if (label.toLowerCase() == day.toLowerCase() ||
        label.toLowerCase() == day.substring(0, 3).toLowerCase() ||
        label.toLowerCase() == 'day ${i + 1}') {
      return day;
    }
  }
  return label;
}

String shortPlanDay(String value) {
  final full = fullPlanDay(value);
  return weekDays.contains(full) ? full.substring(0, 3).toUpperCase() : full;
}

/// Seven-day training blocks counted from the assigned programme start date.
int trainingWeek(DateTime start, DateTime date) {
  final elapsed = DateTime.utc(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime.utc(start.year, start.month, start.day)).inDays;
  return elapsed < 0 ? 1 : elapsed ~/ 7 + 1;
}
