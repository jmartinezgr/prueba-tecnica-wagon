// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/features/home/domain/days_service.dart';
import 'package:mobile/features/home/presentation/views/createTask/widgets/custom_text_form_field.dart';
import 'package:mobile/features/home/presentation/views/createTask/widgets/date_picker_field.dart';
import 'package:mobile/features/home/presentation/views/createTask/widgets/gradient_button.dart';
import 'package:mobile/features/home/presentation/views/createTask/widgets/loading_button.dart';
import 'package:mobile/shared/services/api_service.dart';

// Clase para manejar validaciones
class TaskValidation {
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

// Vista principal simplificada
class CreateTaskView extends StatefulWidget {
  const CreateTaskView({super.key});

  @override
  State<CreateTaskView> createState() => _CreateTaskViewState();
}

class _CreateTaskViewState extends State<CreateTaskView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _clearDate() {
    setState(() => _selectedDate = null);
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final taskData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'estimatedDate': DaysService().formatToISO(_selectedDate),
      };

      final response = await _apiService.post(
        'tasks',
        taskData,
        context: context,
      );
      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        if (mounted) {
          _showMessage('Tarea creada exitosamente', Colors.green);
          _clearForm();
        }
      } else {
        if (mounted) {
          _showMessage('Error: ${data['message']}', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error al crear la tarea: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() => _selectedDate = null);
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
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

                _isLoading
                    ? const LoadingButton()
                    : GradientButton(
                        onPressed: _createTask,
                        text: 'Crear Tarea',
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
