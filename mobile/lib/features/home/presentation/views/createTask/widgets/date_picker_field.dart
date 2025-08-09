import 'package:flutter/material.dart';
import 'package:mobile/features/home/presentation/views/createTask/widgets/gradient_button.dart';

// Widget para el selector de fecha
class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onSelectDate;
  final VoidCallback onClearDate;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            readOnly: true,
            controller: TextEditingController(
              text: selectedDate != null
                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                  : '',
            ),
            decoration: InputDecoration(
              labelText: 'Fecha estimada (opcional)',
              prefixIcon: Icon(
                Icons.calendar_today,
                color: Colors.grey.shade600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              hintText: 'Seleccionar fecha',
            ),
          ),
        ),
        const SizedBox(width: 8),
        GradientButton(
          onPressed: onSelectDate,
          text: 'Elegir',
          isCompact: true,
        ),
        if (selectedDate != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onClearDate,
            icon: Icon(Icons.clear, color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }
}
