// home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/home/presentation/views/principal/principal_view.dart';
import 'package:mobile/features/home/presentation/views/unprogrammedTasks/unprogrammed_tasks_view.dart';
import 'package:mobile/features/home/presentation/views/createTask/create_task_view.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:mobile/shared/services/shared_preferences.dart';
import 'package:mobile/shared/widgets/confirm_dialog.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/custom_drawer.dart';
import 'widgets/custom_bottom_navigation_bar.dart';

/// Main screen for authenticated users, manages navigation, user state, and logout.
class HomeScreen extends StatefulWidget {
  /// Creates a HomeScreen widget.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State for HomeScreen, manages navigation, user info, and view refresh logic.
class _HomeScreenState extends State<HomeScreen> {
  /// Service for secure token storage.
  final SecureStorageService secureStorageService = SecureStorageService();

  /// Service for storing user info.
  final UserInfoService userInfoService = UserInfoService();

  /// Current index of the bottom navigation bar.
  int _currentIndex = 0;

  /// Current user info, loaded from storage.
  Map<String, dynamic>? user;

  // Keys to force view rebuilds
  GlobalKey<State> _principalViewKey = GlobalKey<State>();
  GlobalKey<State> _unprogrammedTasksKey = GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  /// Loads user info from storage and updates state.
  Future<void> _loadUser() async {
    final loadedUser = await userInfoService.getUser();
    if (mounted) {
      setState(() {
        user = loadedUser;
      });
    }
  }

  /// Shows a confirmation dialog and logs out the user if confirmed.
  Future<void> _logout() async {
    final shouldLogout = await ConfirmDialog.show(
      context: context,
      title: 'Cerrar sesión',
      message: '¿Estás seguro de que deseas cerrar sesión?',
      confirmText: 'Cerrar sesión',
      cancelText: 'Cancelar',
      icon: Icons.logout,
      iconColor: Colors.red,
      confirmColor: Colors.redAccent,
    );

    if (shouldLogout) {
      await secureStorageService.deleteAccess();
      await secureStorageService.deleteRefresh();
      await userInfoService.deleteUser();
      if (mounted) context.go('/auth');
    }
  }

  /// Handles tab changes in the bottom navigation bar and refreshes views as needed.
  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // If returning to Dashboard (index 0), force reload
    if (index == 0) {
      _refreshPrincipalView();
    }

    // If returning to Unprogrammed Tasks (index 2), force reload
    if (index == 2) {
      _refreshUnprogrammedTasks();
    }
  }

  /// Forces the PrincipalView to rebuild by assigning a new key.
  void _refreshPrincipalView() {
    setState(() {
      _principalViewKey = GlobalKey<State>();
    });
  }

  /// Forces the UnprogrammedTasksView to rebuild by assigning a new key.
  void _refreshUnprogrammedTasks() {
    setState(() {
      _unprogrammedTasksKey = GlobalKey<State>();
    });
  }

  /// Navigates to the edit task screen and refreshes views on save.
  void _editTask(taskId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateTaskView(
          taskId: taskId,
          onTaskSaved: () {
            // Refresh views when the task is saved
            _refreshPrincipalView();
            _refreshUnprogrammedTasks();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  /// Returns the list of main screens for the IndexedStack.
  List<Widget> _getScreens() {
    return [
      PrincipalView(key: _principalViewKey, user: user, onEditTask: _editTask),
      CreateTaskView(
        onTaskSaved: () {
          _refreshPrincipalView();
          _refreshUnprogrammedTasks();
        },
      ),
      UnprogrammedTasksView(key: _unprogrammedTasksKey, onEditTask: _editTask),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Main UI for home: navigation, user info, and view switching.
    return Scaffold(
      appBar: CustomAppBar(currentIndex: _currentIndex, user: user),
      drawer: user != null
          ? CustomDrawer(
              user: user,
              currentIndex: _currentIndex,
              onTabChanged: _onTabChanged,
              onLogout: _logout,
            )
          : null,
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(index: _currentIndex, children: _getScreens()),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabChanged: _onTabChanged,
      ),
    );
  }
}
