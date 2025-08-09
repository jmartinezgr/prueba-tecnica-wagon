// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/features/home/domain/days_service.dart';
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/widgets/confirm_dialog.dart';

class PrincipalView extends StatefulWidget {
  final Map<String, dynamic>? user;

  const PrincipalView({super.key, required this.user});

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  final ApiService _apiService = ApiService();
  final DaysService _daysService = DaysService();
  List<Map<String, dynamic>> _tasks = [];
  bool _loading = true;
  bool _isLoadingTasks = false;
  List<(String, int, bool, String)> _days = [];
  int _selectedDayIndex = -1;
  int _weekOffset = 0;

  @override
  void initState() {
    super.initState();
    _loadWeekDays();
    _fetchTasksForSelectedDay();
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
      final response = await _apiService.get("tasks?date=$selectedDay");
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

      // TODO: Descomenta cuando esté listo
      // await _apiService.delete("/tasks/$id");

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

        // TODO: Descomenta cuando esté listo
        // await _apiService.put("/tasks/$id", {"isCompleted": value ?? false});

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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Navegación de semana
          _buildWeekNavigation(),

          // Calendario de días
          _buildDaysCalendar(),

          // Lista de tareas
          Expanded(child: _buildTasksList()),
        ],
      ),
    );
  }

  Widget _buildWeekNavigation() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeWeek(-1),
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
            onPressed: () => _changeWeek(1),
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
    if (_weekOffset == 0) return 'Esta semana';
    if (_weekOffset == -1) return 'Semana anterior';
    if (_weekOffset == 1) return 'Próxima semana';
    return _weekOffset < 0
        ? 'Hace ${-_weekOffset} semanas'
        : 'En $_weekOffset semanas';
  }

  Widget _buildDaysCalendar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _days.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isSelected = day.$3;

          return Expanded(
            child: GestureDetector(
              onTap: () => _selectDay(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      day.$1.substring(0, 3), // Primeras 3 letras
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.$2.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTasksList() {
    if (_loading || _isLoadingTasks) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando tareas...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.task_alt_outlined,
                size: 50,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay tareas para este día',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Disfruta tu día libre o añade una nueva tarea',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchTasksForSelectedDay,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return _buildProfessionalTaskCard(
            title: task["title"] ?? "Sin título",
            description: task["description"] ?? "Sin descripción",
            isChecked: task["isCompleted"] ?? false,
            onChanged: (value) => _toggleTask(task["_id"], value),
            onDelete: () => _deleteTask(task["_id"]),
          );
        },
      ),
    );
  }

  Widget _buildProfessionalTaskCard({
    required String title,
    required String description,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Checkbox circular personalizado
            GestureDetector(
              onTap: () => onChanged(!isChecked),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isChecked
                      ? const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isChecked ? null : Colors.transparent,
                  border: isChecked
                      ? null
                      : Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: isChecked
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),

            const SizedBox(width: 16),

            // Contenido de la tarea
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isChecked
                          ? Colors.grey.shade500
                          : const Color(0xFF2D3748),
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: isChecked
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontSize: 14,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Botón de eliminar
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade600,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
