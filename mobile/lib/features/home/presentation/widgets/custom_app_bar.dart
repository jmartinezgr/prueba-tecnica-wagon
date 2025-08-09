// widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'user_avatar.dart';

/// Custom app bar for the home screen, displays page title and user avatar.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Index of the current tab/page.
  final int currentIndex;

  /// User information for displaying avatar.
  final Map<String, dynamic>? user;

  /// Creates a CustomAppBar widget.
  const CustomAppBar({
    super.key,
    required this.currentIndex,
    required this.user,
  });

  /// Returns the title for the current page based on the selected tab.
  String _getPageTitle() {
    switch (currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Agregar Tarea';
      case 2:
        return 'Tareas No Programadas';
      default:
        return 'TaskApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Builds the custom app bar with title, avatar, and notification icon.
    return AppBar(
      elevation: 2,
      backgroundColor: Colors.grey.shade50,
      title: Text(
        _getPageTitle(),
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: Builder(
        builder: (context) => GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Container(
            margin: const EdgeInsets.all(8.0),
            child: UserAvatar(
              user: user,
              size: 32,
              backgroundColor: Colors.blue.shade100,
              textColor: Colors.blue.shade700,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: Colors.black54,
          onPressed: () {
            // Handle notifications
          },
        ),
      ],
    );
  }

  /// Returns the preferred size for the app bar.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
