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

  List<Widget> _getScreens() {
    return [
      PrincipalView(user: user),
      const CreateTaskView(),
      const UnprogrammedTasksView(),
      ProfileView(user: user, onLogout: _logout),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white, // Puedes cambiar el color aquí
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(index: _currentIndex, children: _getScreens()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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
            icon: Icon(Icons.list), // Cambiado a un ícono de lista
            label: 'No Programadas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
