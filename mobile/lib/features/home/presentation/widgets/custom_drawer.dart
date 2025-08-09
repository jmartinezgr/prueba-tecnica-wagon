// widgets/custom_drawer.dart
import 'package:flutter/material.dart';
import 'user_avatar.dart';
import 'drawer_menu_item.dart';

/// Custom navigation drawer for the home screen, displays user info and navigation options.
class CustomDrawer extends StatelessWidget {
  /// User information for displaying in the drawer header.
  final Map<String, dynamic>? user;

  /// Index of the currently selected tab.
  final int currentIndex;

  /// Callback when a tab is selected.
  final Function(int) onTabChanged;

  /// Callback when logout is selected.
  final VoidCallback onLogout;

  /// Creates a CustomDrawer widget.
  const CustomDrawer({
    super.key,
    required this.user,
    required this.currentIndex,
    required this.onTabChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // Builds the navigation drawer with user info and menu items.
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          DrawerMenuItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            isSelected: currentIndex == 0,
            onTap: () {
              Navigator.pop(context);
              onTabChanged(0);
            },
          ),
          DrawerMenuItem(
            icon: Icons.add,
            title: 'Agregar Tarea',
            isSelected: currentIndex == 1,
            onTap: () {
              Navigator.pop(context);
              onTabChanged(1);
            },
          ),
          DrawerMenuItem(
            icon: Icons.list,
            title: 'Tareas No Programadas',
            isSelected: currentIndex == 2,
            onTap: () {
              Navigator.pop(context);
              onTabChanged(2);
            },
          ),
          const Divider(),
          DrawerMenuItem(
            icon: Icons.settings,
            title: 'Configuración',
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          DrawerMenuItem(
            icon: Icons.help,
            title: 'Ayuda',
            onTap: () {
              Navigator.pop(context);
              // Navigate to help
            },
          ),
          const Divider(),
          DrawerMenuItem(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
          ),
        ],
      ),
    );
  }

  /// Builds the drawer header with user name, email, and avatar.
  Widget _buildDrawerHeader() {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(color: Colors.blue),
      accountName: Text(
        user?['name'] ?? 'Usuario',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(user?['email'] ?? 'usuario@ejemplo.com'),
      currentAccountPicture: UserAvatar(
        user: user,
        size: 36,
        backgroundColor: Colors.white,
        textColor: Colors.blue,
        fontSize: 24,
      ),
    );
  }
}
