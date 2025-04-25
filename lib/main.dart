import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/update_screen.dart';
import 'screens/show_screen.dart';
import 'screens/delete_screen.dart';
import 'screens/datos_screen.dart';
import 'screens/tracking_screen.dart'; // Importa la nueva pantalla

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login & Register',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/show': (context) => ShowScreen(),
        '/update': (context) => UpdateScreen(),
        '/delete': (context) => DeleteScreen(),
        '/datos': (context) => DatosScreen(),
        '/tracking': (context) => TrackingScreen(
              userId: ModalRoute.of(context)!.settings.arguments as int,
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/tracking') {
          return MaterialPageRoute(
            builder: (context) => TrackingScreen(
              userId: settings.arguments as int,
            ),
          );
        }
        return null;
      },
    );
  }
}