class DaysService {
  /// Retorna una lista de tuplas (díaNombre, díaNúmero, seleccionado, fechaISO)
  /// [offsetWeeks] -> 0 = semana actual, -1 = anterior, +1 = siguiente, etc.
  /// Si offsetWeeks < 0 => selecciona Domingo, si > 0 => selecciona Lunes, si 0 => día actual
  List<(String, int, bool, String)> getWeekDays({int offsetWeeks = 0}) {
    final now = DateTime.now();

    // Ajustar la fecha base según el desplazamiento de semanas
    final baseDate = now.add(Duration(days: offsetWeeks * 7));

    // Encontrar el lunes de la semana correspondiente
    final monday = baseDate.subtract(Duration(days: baseDate.weekday - 1));

    // Definir días de la semana
    final daysNames = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    // Determinar índice del día seleccionado
    int selectedIndex;
    if (offsetWeeks == 0) {
      selectedIndex = now.weekday - 1; // día actual
    } else if (offsetWeeks < 0) {
      selectedIndex = 6; // domingo
    } else {
      selectedIndex = 0; // lunes
    }

    // Generar lista de tuplas
    final daysList = List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      final fechaISO =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      return (daysNames[index], date.day, index == selectedIndex, fechaISO);
    });

    return daysList;
  }

  String? formatToISO(DateTime? date) {
    if (date == null) return null;
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }
}
