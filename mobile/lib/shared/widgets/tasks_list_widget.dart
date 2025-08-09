import 'package:flutter/material.dart';
import 'task_card_widget.dart';

class TasksListWidget extends StatelessWidget {
  final bool loading;
  final bool isLoadingTasks;
  final List<Map<String, dynamic>> tasks;
  final Future<void> Function() onRefresh;
  final Function(dynamic, bool?) onToggleTask;
  final Function(dynamic) onDeleteTask;
  final Function(dynamic) onEditTask;

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
    if (loading || isLoadingTasks) {
      return _buildLoadingState();
    }
    // RefreshIndicator envuelve tanto la lista como el estado vacío
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: tasks.isEmpty
          ? _buildEmptyStateWithScroll(
              context,
            ) // Estado vacío con scroll habilitado
          : _buildTasksList(), // Lista normal
    );
  }

  /// Widget principal de la lista de tareas con scroll
  Widget _buildTasksList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(), // Permite scroll siempre
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

  /// Estado de carga sin RefreshIndicator (para evitar conflicto)
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

  /// Estado vacío con scroll habilitado para permitir pull-to-refresh
  Widget _buildEmptyStateWithScroll(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6, // Altura mínima
          child: _buildEmptyStateContent(),
        ),
      ],
    );
  }

  /// Contenido del estado vacío reutilizable
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
