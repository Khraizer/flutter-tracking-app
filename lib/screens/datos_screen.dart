import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DatosScreen extends StatefulWidget {
  @override
  _DatosScreenState createState() => _DatosScreenState();
}

class _DatosScreenState extends State<DatosScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('https://tracking-api-l4v2.onrender.com/show'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = List<Map<String, dynamic>>.from(data['users'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error del servidor: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _sortUsers(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _users.sort((a, b) {
        final columnField = _getColumnField(columnIndex);
        var aValue = a[columnField] ?? '';
        var bValue = b[columnField] ?? '';

        if (aValue is String) aValue = aValue.toLowerCase();
        if (bValue is String) bValue = bValue.toLowerCase();

        return ascending
            ? (aValue as Comparable).compareTo(bValue)
            : (bValue as Comparable).compareTo(aValue);
      });
    });
  }

  String _getColumnField(int columnIndex) {
    switch (columnIndex) {
      case 0:
        return 'id';
      case 1:
        return 'email';
      case 2:
        return 'telefono';
      case 3:
        return 'placa';
      case 4:
        return 'tipo_vehiculo';
      default:
        return 'id';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registros de Usuarios'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchUsers,
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchUsers,
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child:
            Text('No hay usuarios registrados', style: TextStyle(fontSize: 18)),
      );
    }

    return _buildUsersTable();
  }

  Widget _buildUsersTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          columnSpacing: 20,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: [
            DataColumn(
              label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
              numeric: true,
              onSort: _sortUsers,
            ),
            DataColumn(
              label:
                  Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
              onSort: _sortUsers,
            ),
            DataColumn(
              label: Text('Teléfono',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onSort: _sortUsers,
            ),
            DataColumn(
              label:
                  Text('Placa', style: TextStyle(fontWeight: FontWeight.bold)),
              onSort: _sortUsers,
            ),
            DataColumn(
              label: Text('Tipo Vehículo',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onSort: _sortUsers,
            ),
          ],
          rows: _users.map((user) {
            return DataRow(
              cells: [
                DataCell(Text(user['id']?.toString() ?? 'N/A')),
                DataCell(
                  Text(
                    user['email'] ?? 'Sin email',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(Text(user['telefono'] ?? 'N/A')),
                DataCell(Text(user['placa']?.toUpperCase() ?? 'N/A')),
                DataCell(Text(
                  user['tipo_vehiculo'] ?? 'N/A',
                  style: TextStyle(
                    color: _getVehicleTypeColor(user['tipo_vehiculo']),
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getVehicleTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'carro':
        return Colors.blue;
      case 'moto':
        return Colors.green;
      case 'camión':
        return Colors.orange;
      case 'furgoneta':
        return Colors.purple;
      default:
        return Colors.black;
    }
  }
}
