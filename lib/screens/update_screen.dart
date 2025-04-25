import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateScreen extends StatefulWidget {
  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  
  // Lista normalizada de tipos de vehículo
  final List<String> vehicleTypes = ['Carro', 'Moto', 'Camión', 'Furgoneta', 'Otro'];
  String _selectedVehicleType = 'Carro';
  String _oldEmail = '';

  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (userData != null) {
      _oldEmail = userData['email'];
      _emailController.text = userData['email'];
      _passwordController.text = userData['password'] ?? '';
      _phoneController.text = userData['telefono'] ?? '';
      _plateController.text = userData['placa'] ?? '';
      
      // Normalización del tipo de vehículo
      String vehicleType = userData['tipo_vehiculo'] ?? 'Carro';
      _selectedVehicleType = vehicleTypes.firstWhere(
        (type) => _normalizeString(type) == _normalizeString(vehicleType),
        orElse: () => 'Carro'
      );
      
      debugPrint('Valor recibido del backend: $vehicleType');
      debugPrint('Valor normalizado seleccionado: $_selectedVehicleType');
    } else {
      setState(() {
        _errorMessage = 'No se recibieron datos del usuario';
      });
      Future.delayed(Duration.zero, () {
        Navigator.pop(context);
      });
    }
  }

  // Función para normalizar strings (quitar acentos y convertir a minúsculas)
  String _normalizeString(String input) {
    return input.toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n');
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/update'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
          'telefono': _phoneController.text,
          'placa': _plateController.text,
          'tipo_vehiculo': _selectedVehicleType,
          'oldEmail': _oldEmail,
        }),
      );

      final responseBody = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        _showSuccessDialog();
        Navigator.pushReplacementNamed(
          context,
          '/show',
          arguments: {
            'email': _emailController.text,
            'password': _passwordController.text,
            'telefono': _phoneController.text,
            'placa': _plateController.text,
            'tipo_vehiculo': _selectedVehicleType
          },
        );
      } else {
        setState(() {
          _errorMessage = responseBody['detail'] ?? 'Error al actualizar datos';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Actualización Exitosa!'),
          content: Text('Tus datos se han actualizado correctamente.'),
          actions: [
            TextButton(
              child: Text('Aceptar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actualizar Datos'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Nuevo correo electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un correo';
                  }
                  if (!value.contains('@')) {
                    return 'Ingrese un correo válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su teléfono';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _plateController,
                decoration: InputDecoration(
                  labelText: 'Placa del vehículo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la placa';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration: InputDecoration(
                  labelText: 'Tipo de vehículo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.emoji_transportation),
                ),
                items: vehicleTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedVehicleType = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione un tipo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _update,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('ACTUALIZAR DATOS',
                          style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _plateController.dispose();
    super.dispose();
  }
}