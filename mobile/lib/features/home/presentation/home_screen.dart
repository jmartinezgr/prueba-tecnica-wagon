import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/home/presentation/views/principal/principal_view.dart';
import 'package:mobile/features/home/presentation/views/unprogrammed_tasks_view.dart';
import 'package:mobile/features/home/presentation/views/profile_view.dart';
import 'package:mobile/features/home/presentation/views/createTask/create_task_view.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:mobile/shared/services/shared_preferences.dart';

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
    await secureStorageService.deleteAccess();
    await secureStorageService.deleteRefresh();
    await userInfoService.deleteUser();
    if (mounted) context.go('/auth');
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
    // Forzar reconstrucción del PrincipalView creando un nuevo key
    setState(() {
      _principalViewKey = GlobalKey<State>();
    });
  }

  void _refreshUnprogrammedTasks() {
    // Forzar reconstrucción del UnprogrammedTasksView creando un nuevo key
    setState(() {
      _unprogrammedTasksKey = GlobalKey<State>();
    });
  }

  List<Widget> _getScreens() {
    return [
      PrincipalView(key: _principalViewKey, user: user),
      const CreateTaskView(),
      UnprogrammedTasksView(key: _unprogrammedTasksKey),
      ProfileView(user: user, onLogout: _logout),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 2, backgroundColor: Colors.white),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(index: _currentIndex, children: _getScreens()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged, // Usar la nueva función
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
