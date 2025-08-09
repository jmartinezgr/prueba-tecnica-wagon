import 'package:flutter/material.dart';
import 'package:mobile/shared/services/api_service.dart';

class ProfileView extends StatefulWidget {
  final Map<String, dynamic>? user;
  final VoidCallback onLogout;

  const ProfileView({super.key, required this.user, required this.onLogout});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Text(
              widget.user!['name'][0].toString().toUpperCase(),
              style: const TextStyle(fontSize: 32, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.user!['name'],
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            widget.user!['email'],
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),

          _buildProfileOption(
            icon: Icons.person,
            title: 'Información personal',
            subtitle: 'Edita tu perfil',
            onTap: () => _editProfile(),
          ),
          _buildProfileOption(
            icon: Icons.security,
            title: 'Seguridad',
            subtitle: 'Cambiar contraseña',
            onTap: () => _changePassword(),
          ),
          _buildProfileOption(
            icon: Icons.help,
            title: 'Ayuda',
            subtitle: 'Centro de ayuda',
            onTap: () => _openHelp(),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _editProfile() async {
    // Aquí puedes hacer una llamada a tu API para actualizar el perfil
    try {
      await _apiService.post('/profile/update', {
        'name': 'Nuevo nombre',
        // otros campos...
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _changePassword() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cambiar contraseña...')));
  }

  void _openHelp() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Abriendo ayuda...')));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro que quieres cerrar sesión?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Cerrar Sesión'),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onLogout();
              },
            ),
          ],
        );
      },
    );
  }
}
