// widgets/drawer_menu_item.dart
import 'package:flutter/material.dart';

/// Widget for a single menu item in the navigation drawer.
class DrawerMenuItem extends StatelessWidget {
  /// Icon to display for the menu item.
  final IconData icon;

  /// Title text for the menu item.
  final String title;

  /// Whether this item is currently selected.
  final bool isSelected;

  /// Callback when the item is tapped.
  final VoidCallback onTap;

  /// Creates a DrawerMenuItem widget.
  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Builds a styled ListTile for a drawer menu item.
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : null),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : null,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      onTap: onTap,
    );
  }
}
