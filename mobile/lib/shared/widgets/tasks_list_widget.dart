import 'package:flutter/material.dart';
import 'task_card_widget.dart';

/// Displays a list of tasks with support for loading, empty, and refresh states.
class TasksListWidget extends StatelessWidget {
  /// Whether the overall app is loading.
  final bool loading;

  /// Whether the tasks are being loaded.
  final bool isLoadingTasks;

  /// List of task objects to display.
  final List<Map<String, dynamic>> tasks;

  /// Callback to refresh the list (pull-to-refresh).
  final Future<void> Function() onRefresh;

  /// Callback when a task's completion state is toggled.
  final Function(dynamic, bool?) onToggleTask;

  /// Callback when a task is deleted.
  final Function(dynamic) onDeleteTask;

  /// Callback when a task is edited.
  final Function(dynamic) onEditTask;

  /// Creates a TasksListWidget.
  const TasksListWidget({
    super.key,
    required this.loading,
    required this.isLoadingTasks,
    required this.tasks,
    required this.onRefresh,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onEditTask,
  });

  @override
  Widget build(BuildContext context) {
    // Show loading indicator if loading.
    if (loading || isLoadingTasks) {
      return _buildLoadingState();
    }
    // Wraps the list or empty state with pull-to-refresh.
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: tasks.isEmpty
          ? _buildEmptyStateWithScroll(
              context,
            ) // Empty state with scroll enabled
          : _buildTasksList(), // Normal list
    );
  }

  /// Builds the main scrollable list of tasks.
  Widget _buildTasksList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCardWidget(
          taskId: task["_id"],
          title: task["title"] ?? "Sin título",
          description: task["description"] ?? "Sin descripción",
          isChecked: task["isCompleted"] ?? false,
          onChanged: (value) => onToggleTask(task["_id"], value),
          onDelete: () => onDeleteTask(task["_id"]),
          onEdit: onEditTask,
        );
      },
    );
  }

  /// Builds the loading state widget (centered spinner and message).
  Widget _buildLoadingState() {
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

  /// Builds the empty state widget with scroll enabled for pull-to-refresh.
  Widget _buildEmptyStateWithScroll(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: _buildEmptyStateContent(),
        ),
      ],
    );
  }

  /// Builds the content for the empty state (icon and messages).
  Widget _buildEmptyStateContent() {
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
            'Visualiza las tareas o añade una nueva',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          Text(
            'Desliza hacia abajo para recargar',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
