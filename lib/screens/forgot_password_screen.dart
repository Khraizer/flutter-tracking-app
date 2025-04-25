import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

Future<void> _sendResetCode() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
    _message = '';
  });

  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/forgot_password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': _emailController.text}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Navigator.pushNamed(
        context,
        '/reset',
        arguments: {'email': _emailController.text},
      );
    } else {
      // Manejo mejorado para errores 500 y otros
      final errorMsg = _handleServerError(response.statusCode, responseData);
      setState(() {
        _message = errorMsg;
      });
    }
  } catch (e) {
    setState(() {
      _message = 'Error al conectar con el servidor. Por favor, inténtalo de nuevo más tarde.';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

String _handleServerError(int statusCode, Map<String, dynamic>? responseData) {
  switch (statusCode) {
    case 404:
      return 'El correo electrónico no está registrado';
    case 500:
      return 'Error interno del servidor. Por favor, contacta al soporte técnico.';
    default:
      return responseData?['message']?.toString() ?? 
             'Error desconocido (Código: $statusCode)';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 80),
              Icon(
                Icons.lock_reset,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 20),
              Text(
                'Recuperar Contraseña',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Ingresa tu correo electrónico para recibir un código de verificación',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su correo';
                  }
                  if (!value.contains('@')) {
                    return 'Ingrese un correo válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendResetCode,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'ENVIAR CÓDIGO',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
              SizedBox(height: 20),
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _message,
                    style: TextStyle(
                      color: _message.contains('éxito') ? Colors.green : Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Volver al Login',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
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
    super.dispose();
  }
}