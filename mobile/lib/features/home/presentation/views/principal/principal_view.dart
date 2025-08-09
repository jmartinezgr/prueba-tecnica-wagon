// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/features/home/domain/days_service.dart';
import 'package:mobile/features/home/presentation/views/principal/widgets/days_calendar_widget.dart';
import 'package:mobile/shared/widgets/tasks_list_widget.dart';
import 'package:mobile/features/home/presentation/views/principal/widgets/week_navigation_widget.dart';
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/widgets/confirm_dialog.dart';

/// Main view for displaying the user's week, days, and tasks list.
/// Handles week navigation, day selection, and task actions (edit, delete, toggle).
class PrincipalView extends StatefulWidget {
  /// User info (may be null if not loaded).
  final Map<String, dynamic>? user;

  /// Callback to edit a task.
  final Function(dynamic) onEditTask;

  /// Creates a PrincipalView widget.
  const PrincipalView({
    super.key,
    required this.user,
    required this.onEditTask,
  });

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

/// State for PrincipalView. Manages week/day navigation, task loading, and task actions.
class _PrincipalViewState extends State<PrincipalView>
    with AutomaticKeepAliveClientMixin {
  /// Service for API requests.
  final ApiService _apiService = ApiService();

  /// Service for week/day calculations.
  final DaysService _daysService = DaysService();

  /// List of tasks for the selected day.
  List<Map<String, dynamic>> _tasks = [];

  /// Whether the view is loading for the first time.
  bool _loading = true;

  /// Whether tasks are being loaded for the selected day.
  bool _isLoadingTasks = false;

  /// List of days in the current week (tuple: name, number, selected, isoDate).
  List<(String, int, bool, String)> _days = [];

  /// Index of the currently selected day.
  int _selectedDayIndex = -1;

  /// Offset from the current week (0 = this week).
  int _weekOffset = 0;

  /// Keep state when switching tabs.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeView();
  }

  /// Initializes the view: loads week days and fetches tasks for the selected day.
  Future<void> _initializeView() async {
    _loadWeekDays();
    await _fetchTasksForSelectedDay();
  }

  /// Loads the days for the current week and selects the current day.
  void _loadWeekDays() {
    _days = _daysService.getWeekDays(offsetWeeks: _weekOffset);
    _selectedDayIndex = _days.indexWhere((day) => day.$3); // Find selected day
  }

  /// Fetches tasks from the backend for the selected day.
  Future<void> _fetchTasksForSelectedDay() async {
    if (_selectedDayIndex == -1) return;

    setState(() {
      _isLoadingTasks = true;
    });

    try {
      final selectedDay = _days[_selectedDayIndex].$4;
      final response = await _apiService.get(
        "tasks?date=$selectedDay",
        context: context,
      );
      final data = json.decode(response.body) as List<dynamic>;
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(data);
        _loading = false;
        _isLoadingTasks = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _isLoadingTasks = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cargando tareas: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  /// Public method to refresh the view from outside.
  Future<void> refresh() async {
    await _initializeView();
  }

  /// Deletes a task after confirmation dialog and updates the list.
  Future<void> _deleteTask(dynamic id) async {
    try {
      // Show confirmation dialog
      final shouldDelete = await ConfirmDialog.show(
        context: context,
        title: 'Confirmar eliminación',
        message: '¿Estás seguro de que deseas eliminar esta tarea?',
        confirmText: 'Eliminar',
        cancelText: 'Cancelar',
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.orange.shade600,
        confirmColor: Colors.red.shade600,
      );

      if (!shouldDelete) return;

      await _apiService.delete("tasks/$id", context: context);

      setState(() {
        _tasks.removeWhere((task) => task["_id"] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tarea eliminada exitosamente'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar tarea: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  /// Toggles a task's completion status and updates the backend.
  Future<void> _toggleTask(dynamic id, bool? value) async {
    try {
      final index = _tasks.indexWhere((task) => task["_id"] == id);
      if (index != -1) {
        setState(() {
          _tasks[index]["isCompleted"] = value ?? false;
        });

        await _apiService.patch("tasks/$id", {
          "isCompleted": value ?? false,
        }, context: context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value == true
                  ? 'Tarea completada'
                  : 'Tarea marcada como pendiente',
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar tarea: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  /// Selects a day, updates the selected index, and fetches tasks for that day.
  void _selectDay(int index) {
    setState(() {
      // Unselect previous day
      _days = _days.map((day) => (day.$1, day.$2, false, day.$4)).toList();

      // Select new day
      _days[index] = (_days[index].$1, _days[index].$2, true, _days[index].$4);
      _selectedDayIndex = index;
    });

    _fetchTasksForSelectedDay();
  }

  /// Changes the week offset and reloads days/tasks.
  void _changeWeek(int offset) {
    setState(() {
      _weekOffset += offset;
      _loadWeekDays();
    });
    _fetchTasksForSelectedDay();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Week navigation
          WeekNavigationWidget(
            weekOffset: _weekOffset,
            onPreviousWeek: () => _changeWeek(-1),
            onNextWeek: () => _changeWeek(1),
          ),

          // Days calendar
          DaysCalendarWidget(days: _days, onDaySelected: _selectDay),

          // Tasks list
          Expanded(
            child: TasksListWidget(
              loading: _loading,
              isLoadingTasks: _isLoadingTasks,
              tasks: _tasks,
              onRefresh: _fetchTasksForSelectedDay,
              onToggleTask: _toggleTask,
              onDeleteTask: _deleteTask,
              onEditTask: widget.onEditTask,
            ),
          ),
        ],
      ),
    );
  }
}
