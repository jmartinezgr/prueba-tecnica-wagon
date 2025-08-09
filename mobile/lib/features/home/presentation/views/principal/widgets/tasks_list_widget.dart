import 'package:flutter/material.dart';
import 'task_card_widget.dart';

class TasksListWidget extends StatelessWidget {
  final bool loading;
  final bool isLoadingTasks;
  final List<Map<String, dynamic>> tasks;
  final Future<void> Function() onRefresh;
  final Function(dynamic, bool?) onToggleTask;
  final Function(dynamic) onDeleteTask;

  const TasksListWidget({
    super.key,
    required this.loading,
    required this.isLoadingTasks,
    required this.tasks,
    required this.onRefresh,
    required this.onToggleTask,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    if (loading || isLoadingTasks) {
      return _buildLoadingState();
    }

    if (tasks.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCardWidget(
            title: task["title"] ?? "Sin título",
            description: task["description"] ?? "Sin descripción",
            isChecked: task["isCompleted"] ?? false,
            onChanged: (value) => onToggleTask(task["_id"], value),
            onDelete: () => onDeleteTask(task["_id"]),
          );
        },
      ),
    );
  }

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

  Widget _buildEmptyState() {
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
}
