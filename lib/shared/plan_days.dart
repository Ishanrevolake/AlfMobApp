const weekDays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

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
