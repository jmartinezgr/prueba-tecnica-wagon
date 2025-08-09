/// Service for week/day calculations and date formatting.
class DaysService {
  /// Returns a list of tuples (dayName, dayNumber, selected, isoDate) for the week.
  /// [offsetWeeks]: 0 = current week, -1 = previous, +1 = next, etc.
  /// If offsetWeeks < 0 selects Sunday, > 0 selects Monday, 0 selects today.
  List<(String, int, bool, String)> getWeekDays({int offsetWeeks = 0}) {
    final now = DateTime.now();

    // Adjust base date by week offset
    final baseDate = now.add(Duration(days: offsetWeeks * 7));

    // Find Monday of the target week
    final monday = baseDate.subtract(Duration(days: baseDate.weekday - 1));

    // Weekday names
    final daysNames = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    // Determine selected day index
    int selectedIndex;
    if (offsetWeeks == 0) {
      selectedIndex = now.weekday - 1; // today
    } else if (offsetWeeks < 0) {
      selectedIndex = 6; // Sunday
    } else {
      selectedIndex = 0; // Monday
    }

    // Generate list of tuples for each day
    final daysList = List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      final fechaISO =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      return (daysNames[index], date.day, index == selectedIndex, fechaISO);
    });

    return daysList;
  }

  /// Formats a DateTime as an ISO date string (yyyy-MM-dd), or null if input is null.
  String? formatToISO(DateTime? date) {
    if (date == null) return null;
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }
}
