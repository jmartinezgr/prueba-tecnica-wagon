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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SecureStorageService secureStorageService = SecureStorageService();
  final UserInfoService userInfoService = UserInfoService();
  int _currentIndex = 0;
  Map<String, dynamic>? user;

  // Keys para forzar reconstrucción de las vistas
  GlobalKey<State> _principalViewKey = GlobalKey<State>();
  GlobalKey<State> _unprogrammedTasksKey = GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final loadedUser = await userInfoService.getUser();
    if (mounted) {
      setState(() {
        user = loadedUser;
      });
    }
  }

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

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Si regresa al Dashboard (índice 0), forzar recarga
    if (index == 0) {
      _refreshPrincipalView();
    }

    // Si regresa a Tareas No Programadas (índice 2), forzar recarga
    if (index == 2) {
      _refreshUnprogrammedTasks();
    }
  }

  void _refreshPrincipalView() {
    setState(() {
      _principalViewKey = GlobalKey<State>();
    });
  }

  void _refreshUnprogrammedTasks() {
    setState(() {
      _unprogrammedTasksKey = GlobalKey<State>();
    });
  }

  // Función para navegar a editar tarea
  void _editTask(taskId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateTaskView(
          taskId: taskId,
          onTaskSaved: () {
            // Actualizar las vistas cuando se guarde la tarea
            _refreshPrincipalView();
            _refreshUnprogrammedTasks();
            Navigator.of(context).pop(); // Cerrar la pantalla de edición
          },
        ),
      ),
    );
  }

  List<Widget> _getScreens() {
    return [
      PrincipalView(
        key: _principalViewKey,
        user: user,
        onEditTask: _editTask, // Pasar la función de edición
      ),
      CreateTaskView(
        onTaskSaved: () {
          // Cuando se cree una nueva tarea, actualizar las vistas
          _refreshPrincipalView();
          _refreshUnprogrammedTasks();
        },
      ),
      UnprogrammedTasksView(
        key: _unprogrammedTasksKey,
        onEditTask: _editTask, // Pasar la función de edición
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
