// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/widgets/tasks_list_widget.dart';

// Vista principal de Tareas No Programadas
class UnprogrammedTasksView extends StatefulWidget {
  const UnprogrammedTasksView({super.key});

  @override
  State<UnprogrammedTasksView> createState() => _UnprogrammedTasksViewState();
}

class _UnprogrammedTasksViewState extends State<UnprogrammedTasksView> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;
  bool _isLoadingTasks = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      setState(() => _isLoading = true);

      // Cambia este endpoint por el que necesites para tareas no programadas
      final response = await _apiService.get('/tasks/unprogrammed');
      final data = json.decode(response.body);

      if (mounted) {
        setState(() {
          _tasks = List<Map<String, dynamic>>.from(data['tasks'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showErrorMessage('Error cargando tareas: $e');
    }
  }

  Future<void> _toggleTaskCompletion(taskId, bool? isCompleted) async {
    try {
      setState(() => _isLoadingTasks = true);

      // Cambia este endpoint por el que necesites para actualizar tareas
      await _apiService.patch('/tasks/$taskId', {
        'isCompleted': isCompleted ?? false,
      });

      // Actualizar el estado local
      setState(() {
        final index = _tasks.indexWhere((task) => task['_id'] == taskId);
        if (index != -1) {
          _tasks[index]['isCompleted'] = isCompleted ?? false;
        }
        _isLoadingTasks = false;
      });

      _showSuccessMessage(
        isCompleted == true
            ? 'Tarea completada'
            : 'Tarea marcada como pendiente',
      );
    } catch (e) {
      setState(() => _isLoadingTasks = false);
      _showErrorMessage('Error actualizando tarea: $e');
    }
  }

  Future<void> _deleteTask(taskId) async {
    try {
      setState(() => _isLoadingTasks = true);

      // Cambia este endpoint por el que necesites para eliminar tareas
      await _apiService.delete('/tasks/$taskId');

      // Remover de la lista local
      setState(() {
        _tasks.removeWhere((task) => task['_id'] == taskId);
        _isLoadingTasks = false;
      });

      _showSuccessMessage('Tarea eliminada');
    } catch (e) {
      setState(() => _isLoadingTasks = false);
      _showErrorMessage('Error eliminando tarea: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tareas No Programadas')),
      body: TasksListWidget(
        loading: _isLoading,
        isLoadingTasks: _isLoadingTasks,
        tasks: _tasks,
        onRefresh: _loadTasks,
        onToggleTask: _toggleTaskCompletion,
        onDeleteTask: _deleteTask,
      ),
    );
  }
}
