// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/widgets/confirm_dialog.dart';
import 'package:mobile/shared/widgets/tasks_list_widget.dart';

// Vista principal de Tareas No Programadas
class UnprogrammedTasksView extends StatefulWidget {
  const UnprogrammedTasksView({super.key});

  @override
  State<UnprogrammedTasksView> createState() => _UnprogrammedTasksViewState();
}

class _UnprogrammedTasksViewState extends State<UnprogrammedTasksView>
    with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;
  bool _isLoadingTasks = false;

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
    await _loadTasks();
  }

  // Método público para recargar desde el exterior
  Future<void> refresh() async {
    await _initializeView();
  }

  Future<void> _loadTasks() async {
    try {
      setState(() => _isLoading = true);

      // Cambia este endpoint por el que necesites para tareas no programadas
      final response = await _apiService.get(
        'tasks?sheduled=false',
        context: context,
      );
      final data = json.decode(response.body);
      if (mounted) {
        setState(() {
          _tasks = List<Map<String, dynamic>>.from(data ?? []);
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
      await _apiService.patch('tasks/$taskId', {
        'isCompleted': isCompleted ?? false,
      }, context: context);

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

      // Cambia este endpoint por el que necesites para eliminar tareas
      await _apiService.delete('tasks/$taskId', context: context);

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
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin

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
