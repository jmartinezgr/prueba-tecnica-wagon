import 'package:flutter/material.dart';

class ConfirmDialog {
  /// Muestra un diálogo de confirmación y retorna `true` si el usuario confirma.
  static Future<bool> show({
    required BuildContext context,
    String title = 'Confirmar acción',
    String message = '¿Estás seguro de que deseas continuar?',
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    IconData icon = Icons.help_outline,
    Color iconColor = Colors.blue,
    Color confirmColor = Colors.red,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(width: 8),
                  Expanded(child: Text(title)),
                ],
              ),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    cancelText,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
