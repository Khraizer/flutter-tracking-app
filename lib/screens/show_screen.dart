import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowScreen extends StatefulWidget {
  const ShowScreen({Key? key}) : super(key: key);

  @override
  State<ShowScreen> createState() => _ShowScreenState();
}

class _ShowScreenState extends State<ShowScreen> {
  late Map<String, dynamic> _userData;
  bool _isRefreshing = false;
  String _errorMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (userData != null && userData['id'] != null) {
      _userData = userData;
      debugPrint('Datos de usuario recibidos: $_userData'); // Para verificar
    } else {
      setState(() {
        _errorMessage = 'Datos de usuario no válidos';
      });
      if (mounted) {
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacementNamed(context, '/');
        });
      }
    }
  }

  Future<void> _refreshUserData() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      final response = await http.get(
        Uri.parse('http://TU_SERVIDOR/show'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final users = data['users'] as List;
        final currentUser = users.firstWhere(
          (user) => user['email'] == _userData['email'],
          orElse: () => {},
        );

        if (currentUser.isNotEmpty && currentUser['id'] != null && mounted) {
          setState(() {
            _userData = currentUser;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Datos actualizados')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Widget _buildUserInfoItem(String label, dynamic value) {
    final displayValue = value?.toString() ?? 'No especificado';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_errorMessage)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.refresh),
            onPressed: _refreshUserData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserInfoItem('ID', _userData['id']),
                    const Divider(),
                    _buildUserInfoItem('Correo electrónico', _userData['email']),
                    const Divider(),
                    _buildUserInfoItem('Teléfono', _userData['telefono']),
                    const Divider(),
                    _buildUserInfoItem('Placa', _userData['placa']),
                    const Divider(),
                    _buildUserInfoItem('Tipo de vehículo', _userData['tipo_vehiculo']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.track_changes,
          label: 'Monitoreo en Tiempo Real',
          color: Colors.purple,
          onPressed: () {
            if (_userData['id'] == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: No se pudo obtener el ID del usuario'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            Navigator.pushNamed(
              context,
              '/tracking',
              arguments: _userData['id'],
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.edit,
          label: 'Actualizar Datos',
          color: Colors.orange,
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/update',
              arguments: _userData,
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.delete,
          label: 'Eliminar Cuenta',
          color: Colors.red,
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/delete',
              arguments: _userData['email'],
            );
          },
        ),
        const SizedBox(height: 12),
        _buildOutlinedButton(
          icon: Icons.list,
          label: 'Ver Todos los Registros',
          onPressed: () => Navigator.pushNamed(context, '/datos'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildOutlinedButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(color: Theme.of(context).primaryColor),
        ),
        onPressed: onPressed,
      ),
    );
  }
}