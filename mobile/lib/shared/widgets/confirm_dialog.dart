import 'package:flutter/material.dart';

/// Provides a static method to show a confirmation dialog and return the user's choice.
class ConfirmDialog {
  /// Shows a confirmation dialog and returns `true` if the user confirms, `false` otherwise.
  ///
  /// [context]: BuildContext to display the dialog.
  /// [title]: Title of the dialog.
  /// [message]: Message body of the dialog.
  /// [confirmText]: Text for the confirm button.
  /// [cancelText]: Text for the cancel button.
  /// [icon]: Icon to display in the dialog.
  /// [iconColor]: Color of the icon.
  /// [confirmColor]: Color of the confirm button.
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
