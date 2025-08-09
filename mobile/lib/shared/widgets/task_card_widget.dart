// widgets/task_card_widget.dart
import 'package:flutter/material.dart';

/// Widget that displays a task card with title, description, checkbox, and action buttons.
/// Allows editing, deleting, and toggling completion state of a task.
class TaskCardWidget extends StatelessWidget {
  /// Unique identifier for the task.
  final String taskId;

  /// Title of the task.
  final String title;

  /// Description of the task.
  final String description;

  /// Whether the task is marked as completed.
  final bool isChecked;

  /// Callback when the checkbox is toggled.
  final ValueChanged<bool?> onChanged;

  /// Callback when the delete button is pressed.
  final VoidCallback onDelete;

  /// Callback when the edit button or card is tapped.
  final Function(String taskId) onEdit;

  /// Creates a TaskCardWidget.
  const TaskCardWidget({
    super.key,
    required this.taskId,
    required this.title,
    required this.description,
    required this.isChecked,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Makes the entire card tappable for editing.
    return GestureDetector(
      onTap: () => onEdit(taskId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
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
          child: Column(
            children: [
              Row(
                children: [
                  // Custom circular checkbox
                  _buildCustomCheckbox(),
                  const SizedBox(width: 16),

                  // Task content (title and description)
                  Expanded(child: _buildTaskContent()),
                  const SizedBox(width: 12),

                  // Action buttons (edit, delete)
                  _buildActionButtons(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a custom animated circular checkbox for marking task completion.
  Widget _buildCustomCheckbox() {
    return GestureDetector(
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
    );
  }

  /// Builds the main content of the task card: title and description.
  Widget _buildTaskContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isChecked ? Colors.grey.shade500 : const Color(0xFF2D3748),
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
              color: isChecked ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 14,
              decoration: isChecked ? TextDecoration.lineThrough : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// Builds the action buttons for editing and deleting the task.
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit button
        GestureDetector(
          onTap: () => onEdit(taskId),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.edit_outlined,
              color: Colors.blue.shade600,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Delete button
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
    );
  }
}
