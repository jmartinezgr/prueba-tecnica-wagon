import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/home/presentation/views/dashboard_view.dart';
import 'package:mobile/features/home/presentation/views/notifications_view.dart';
import 'package:mobile/features/home/presentation/views/profile_view.dart';
import 'package:mobile/features/home/presentation/views/search_view.dart';
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
      DashboardView(user: user),
      const SearchView(),
      const NotificationsView(),
      ProfileView(user: user, onLogout: _logout),
    ];
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Buscar';
      case 2:
        return 'Notificaciones';
      case 3:
        return 'Perfil';
      default:
        return 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getAppBarTitle()), elevation: 2),
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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
