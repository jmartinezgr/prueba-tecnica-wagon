// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/features/home/domain/days_service.dart';
import 'package:mobile/features/home/presentation/views/principal/widgets/days_calendar_widget.dart';
import 'package:mobile/shared/widgets/tasks_list_widget.dart';
import 'package:mobile/features/home/presentation/views/principal/widgets/week_navigation_widget.dart';
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/widgets/confirm_dialog.dart';

class PrincipalView extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Function(dynamic) onEditTask;

  const PrincipalView({
    super.key,
    required this.user,
    required this.onEditTask,
  });

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView>
    with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  final DaysService _daysService = DaysService();
  List<Map<String, dynamic>> _tasks = [];
  bool _loading = true;
  bool _isLoadingTasks = false;
  List<(String, int, bool, String)> _days = [];
  int _selectedDayIndex = -1;
  int _weekOffset = 0;

  // Para mantener el estado cuando se cambia de pestaña
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeView();
  }

  // Método principal para inicializar/recargar la vista
  Future<void> _initializeView() async {
    _loadWeekDays();
    await _fetchTasksForSelectedDay();
  }

  void _loadWeekDays() {
    _days = _daysService.getWeekDays(offsetWeeks: _weekOffset);
    _selectedDayIndex = _days.indexWhere(
      (day) => day.$3,
    ); // Buscar el día seleccionado
  }

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

  // Método público para recargar desde el exterior
  Future<void> refresh() async {
    await _initializeView();
  }

  Future<void> _deleteTask(dynamic id) async {
    try {
      // Mostrar diálogo de confirmación
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

  void _selectDay(int index) {
    setState(() {
      // Desmarcar el día anterior
      _days = _days.map((day) => (day.$1, day.$2, false, day.$4)).toList();

      // Marcar el nuevo día seleccionado
      _days[index] = (_days[index].$1, _days[index].$2, true, _days[index].$4);
      _selectedDayIndex = index;
    });

    _fetchTasksForSelectedDay();
  }

  void _changeWeek(int offset) {
    setState(() {
      _weekOffset += offset;
      _loadWeekDays();
    });
    _fetchTasksForSelectedDay();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Navegación de semana
          WeekNavigationWidget(
            weekOffset: _weekOffset,
            onPreviousWeek: () => _changeWeek(-1),
            onNextWeek: () => _changeWeek(1),
          ),

          // Calendario de días
          DaysCalendarWidget(days: _days, onDaySelected: _selectDay),

          // Lista de tareas
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
