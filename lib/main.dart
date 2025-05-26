import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/enhanced_dashboard_page.dart';
import 'pages/debug_page.dart';
import 'pages/ventas_page.dart' as ventas;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa sqflite_ffi para Windows/Linux
  if (!kIsWeb && (Platform.isWindows)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextMeal Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        // Tema oscuro por defecto
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          foregroundColor: Colors.white,
        ),
      ),
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/enhanced-dashboard': (context) => const EnhancedDashboardPage(),
        '/debug': (context) => const DebugPage(),
        '/ventas': (context) => const ventas.VentasPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
