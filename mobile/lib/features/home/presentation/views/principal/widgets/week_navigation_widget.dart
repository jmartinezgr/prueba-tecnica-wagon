import 'package:flutter/material.dart';

/// Widget for navigating between weeks. Shows arrows and current week label.
class WeekNavigationWidget extends StatelessWidget {
  /// Offset from the current week (0 = this week).
  final int weekOffset;

  /// Callback for navigating to the previous week.
  final VoidCallback onPreviousWeek;

  /// Callback for navigating to the next week.
  final VoidCallback onNextWeek;

  /// Creates a WeekNavigationWidget.
  const WeekNavigationWidget({
    super.key,
    required this.weekOffset,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPreviousWeek,
            icon: Icon(Icons.chevron_left, color: Colors.grey.shade600),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Text(
            _getWeekTitle(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          IconButton(
            onPressed: onNextWeek,
            icon: Icon(Icons.chevron_right, color: Colors.grey.shade600),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekTitle() {
    if (weekOffset == 0) return 'Esta semana';
    if (weekOffset == -1) return 'Semana anterior';
    if (weekOffset == 1) return 'Próxima semana';
    return weekOffset < 0
        ? 'Hace ${-weekOffset} semanas'
        : 'En $weekOffset semanas';
  }
}
