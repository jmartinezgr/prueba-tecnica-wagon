// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/widgets/confirm_dialog.dart';
import 'package:mobile/shared/widgets/tasks_list_widget.dart';

/// Main view for displaying and managing unprogrammed (unscheduled) tasks.
/// Handles loading, toggling, deleting, and editing tasks.
class UnprogrammedTasksView extends StatefulWidget {
  /// Callback to edit a task.
  final Function(dynamic) onEditTask;

  /// Creates an UnprogrammedTasksView widget.
  const UnprogrammedTasksView({super.key, required this.onEditTask});

  @override
  State<UnprogrammedTasksView> createState() => _UnprogrammedTasksViewState();
}

/// State for UnprogrammedTasksView. Manages loading, toggling, deleting, and editing unprogrammed tasks.
class _UnprogrammedTasksViewState extends State<UnprogrammedTasksView>
    with AutomaticKeepAliveClientMixin {
  /// Service for API requests.
  final ApiService _apiService = ApiService();

  /// List of unprogrammed tasks.
  List<Map<String, dynamic>> _tasks = [];

  /// Whether the view is loading for the first time.
  bool _isLoading = true;

  /// Whether a task action (toggle/delete) is loading.
  bool _isLoadingTasks = false;

  /// Keep state when switching tabs.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeView();
  }

  /// Initializes the view and loads unprogrammed tasks.
  Future<void> _initializeView() async {
    await _loadTasks();
  }

  /// Public method to refresh the view from outside.
  Future<void> refresh() async {
    await _initializeView();
  }

  /// Loads unprogrammed tasks from the backend.
  Future<void> _loadTasks() async {
    try {
      setState(() => _isLoading = true);

      // Fetch unprogrammed tasks (scheduled=false)
      final response = await _apiService.get(
        'tasks?scheduled=false',
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

  /// Toggles a task's completion status and updates the backend.
  Future<void> _toggleTaskCompletion(taskId, bool? isCompleted) async {
    try {
      setState(() => _isLoadingTasks = true);

      await _apiService.patch('tasks/$taskId', {
        'isCompleted': isCompleted ?? false,
      }, context: context);

      // Update local state
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

  /// Deletes a task after confirmation dialog and updates the list.
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

      await _apiService.delete('tasks/$taskId', context: context);

      // Remove from local list
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

  /// Shows a success message in a SnackBar.
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  /// Shows an error message in a SnackBar.
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: TasksListWidget(
        loading: _isLoading,
        isLoadingTasks: _isLoadingTasks,
        tasks: _tasks,
        onRefresh: _loadTasks,
        onToggleTask: _toggleTaskCompletion,
        onDeleteTask: _deleteTask,
        onEditTask: widget.onEditTask, // Pass edit callback
      ),
    );
  }
}
