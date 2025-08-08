import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: user == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Email: ${user!['email']}'),
                  Text('Nombre: ${user!['name']}'),
                  Text('Creado: ${user!['createdAt']}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _logout,
                    child: const Text('Cerrar sesión'),
                  ),
                ],
              ),
      ),
    );
  }
}
