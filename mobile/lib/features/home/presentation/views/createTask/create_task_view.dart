// views/createTask/create_task_view.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/features/home/domain/days_service.dart';
import 'package:mobile/features/home/presentation/views/createTask/widgets/custom_text_form_field.dart';
import 'package:mobile/features/home/presentation/views/createTask/widgets/date_picker_field.dart';
import 'package:mobile/features/home/presentation/views/createTask/widgets/gradient_button.dart';
import 'package:mobile/features/home/presentation/views/createTask/widgets/loading_button.dart';
import 'package:mobile/shared/services/api_service.dart';

/// Utility class for task form validation.
class TaskValidation {
  /// Validates the title field for a task.
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El título es obligatorio';
    }
    if (value.trim().length < 3) {
      return 'El título debe tener al menos 3 caracteres';
    }
    return null;
  }
}

/// Main view for creating or editing a task. Handles form, validation, and API calls.
class CreateTaskView extends StatefulWidget {
  /// If not null, the view is in edit mode for the given task ID.
  final String? taskId;

  /// Callback when a task is successfully saved.
  final Function()? onTaskSaved;

  /// Creates a CreateTaskView widget.
  const CreateTaskView({super.key, this.taskId, this.onTaskSaved});

  @override
  State<CreateTaskView> createState() => _CreateTaskViewState();
}

/// State for CreateTaskView, manages form, loading, and save logic.
class _CreateTaskViewState extends State<CreateTaskView> {
  /// Controller for the title input field.
  final _titleController = TextEditingController();

  /// Controller for the description input field.
  final _descriptionController = TextEditingController();

  /// Key for the task form.
  final _formKey = GlobalKey<FormState>();

  /// API service for backend requests.
  final _apiService = ApiService();

  /// Selected date for the task (optional).
  DateTime? _selectedDate;

  /// Whether the save operation is loading.
  bool _isLoading = false;

  /// Whether the task is being loaded (edit mode).
  bool _isLoadingTask = false;

  /// True if editing an existing task.
  bool get _isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadTask();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Loads task data from the backend if editing, and populates the form.
  Future<void> _loadTask() async {
    if (!_isEditing) return;

    setState(() => _isLoadingTask = true);

    try {
      final response = await _apiService.get(
        'tasks/${widget.taskId}',
        context: context,
      );

      if (response.statusCode == 200) {
        final taskData = json.decode(response.body);

        if (mounted) {
          setState(() {
            _titleController.text = taskData['title'] ?? '';
            _descriptionController.text = taskData['description'] ?? '';

            if (taskData['estimatedDate'] != null) {
              _selectedDate = DateTime.parse(taskData['estimatedDate']);
            }
          });
        }
      } else {
        if (mounted) {
          _showMessage('Error al cargar la tarea', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error al cargar la tarea: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingTask = false);
      }
    }
  }

  /// Shows a date picker dialog and updates the selected date.
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Clears the selected date.
  void _clearDate() {
    setState(() => _selectedDate = null);
  }

  /// Saves the task (create or update) via API, validates form, and shows messages.
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final taskData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'estimatedDate': DaysService().formatToISO(_selectedDate),
      };

      late final response;

      if (_isEditing) {
        // Update existing task
        response = await _apiService.patch(
          'tasks/${widget.taskId}',
          taskData,
          context: context,
        );
      } else {
        // Create new task
        response = await _apiService.post('tasks', taskData, context: context);
      }

      final data = json.decode(response.body);
      final expectedStatusCode = _isEditing ? 200 : 201;

      if (response.statusCode == expectedStatusCode) {
        if (mounted) {
          final message = _isEditing
              ? 'Tarea actualizada exitosamente'
              : 'Tarea creada exitosamente';

          _showMessage(message, Colors.green);

          if (!_isEditing) {
            _clearForm();
          }

          // Call callback if provided
          widget.onTaskSaved?.call();
        }
      } else {
        if (mounted) {
          _showMessage('Error: ${data['message']}', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        final action = _isEditing ? 'actualizar' : 'crear';
        _showMessage('Error al $action la tarea: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Clears the form fields and selected date.
  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() => _selectedDate = null);
  }

  /// Shows a message in a SnackBar with the given color.
  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    // Main UI for creating or editing a task: form, validation, loading, and navigation.
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _isEditing
          ? AppBar(
              title: const Text('Editar Tarea'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 1,
            )
          : null,
      body: SafeArea(
        child: _isLoadingTask
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isEditing) ...[
                        Text(
                          'Nueva Tarea',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Completa los campos para crear una nueva tarea',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      CustomTextFormField(
                        controller: _titleController,
                        labelText: 'Título',
                        prefixIcon: Icons.title,
                        validator: TaskValidation.validateTitle,
                        maxLength: 100,
                      ),
                      const SizedBox(height: 16),

                      CustomTextFormField(
                        controller: _descriptionController,
                        labelText: 'Descripción (opcional)',
                        prefixIcon: Icons.description,
                        maxLines: 3,
                        maxLength: 500,
                      ),
                      const SizedBox(height: 16),

                      DatePickerField(
                        selectedDate: _selectedDate,
                        onSelectDate: _selectDate,
                        onClearDate: _clearDate,
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: _isLoading
                            ? const LoadingButton()
                            : GradientButton(
                                onPressed: _saveTask,
                                text: _isEditing
                                    ? 'Actualizar Tarea'
                                    : 'Crear Tarea',
                              ),
                      ),

                      if (_isEditing) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
