// widgets/custom_bottom_navigation_bar.dart
import 'package:flutter/material.dart';

/// Custom bottom navigation bar for switching between main app sections.
class CustomBottomNavigationBar extends StatelessWidget {
  /// Index of the currently selected tab.
  final int currentIndex;

  /// Callback when a tab is selected.
  final Function(int) onTabChanged;

  /// Creates a CustomBottomNavigationBar widget.
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Builds the bottom navigation bar for main app navigation.
    return BottomNavigationBar(
      backgroundColor: Colors.grey.shade50,
      currentIndex: currentIndex,
      onTap: onTabChanged,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Agregar'),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'No Programadas',
        ),
      ],
    );
  }
}
