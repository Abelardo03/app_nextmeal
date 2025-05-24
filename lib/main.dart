import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/debug_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Importante para inicializar plugins
  
  // Inicializa sqflite_ffi para Windows/Linux
  if (!kIsWeb && (Platform.isWindows)) {
    // Inicializa FFI
    sqfliteFfiInit();
    // Cambia el databaseFactory predeterminado
    databaseFactory = databaseFactoryFfi;
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      routes:{
        '/':(context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/dashboard': (context) => const DashboardPage(),
        '/debug': (context) => const DebugPage(),
      }
    );
  }
}