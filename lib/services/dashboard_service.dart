import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_nextmeal/pages/config.dart';

class DashboardService {
  // Obtener resumen del dashboard
  Future<Map<String, dynamic>> obtenerResumen() async {
    try {
      // Usar URL directa en lugar de método Config que puede no existir
      final url = '${Config.baseUrl}/api/dashboard/resumen';
      print(' URL resumen: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: Config.defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      print(' Response status resumen: ${response.statusCode}');
      print(' Response body resumen: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }

      final data = json.decode(response.body);
      
      // CORREGIDO: Cambiar 'exito' por 'success' para coincidir con el backend
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      } else {
        throw Exception('Error del servidor: ${data['message'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      print(' Error en obtenerResumen: $e');
      rethrow;
    }
  }

  // Obtener estadísticas semanales
  Future<List<Map<String, dynamic>>> obtenerEstadisticasSemanal() async {
    try {
      final url = '${Config.baseUrl}/api/dashboard/estadisticas/semanal';
      print(' URL estadísticas: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: Config.defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      print(' Response status estadísticas: ${response.statusCode}');
      print(' Response body estadísticas: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }

      final data = json.decode(response.body);
      
      // CORREGIDO: Cambiar 'exito' por 'success'
      if (data['success'] == true) {
        final List<dynamic> rawData = data['data'] ?? [];
        return rawData.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error del servidor: ${data['message'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      print(' Error en obtenerEstadisticasSemanal: $e');
      rethrow;
    }
  }

  // Obtener métodos de pago de hoy
  Future<Map<String, dynamic>> obtenerMetodosPagoHoy() async {
    try {
      final url = '${Config.baseUrl}/api/dashboard/metodos-pago/hoy';
      print(' URL métodos pago: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: Config.defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      print(' Response status métodos pago: ${response.statusCode}');
      print(' Response body métodos pago: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }

      final data = json.decode(response.body);
      
      // CORREGIDO: Cambiar 'exito' por 'success'
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      } else {
        throw Exception('Error del servidor: ${data['message'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      print(' Error en obtenerMetodosPagoHoy: $e');
      rethrow;
    }
  }

  // Obtener ventas en tiempo real
  Future<List<Map<String, dynamic>>> obtenerVentasEnTiempoReal() async {
    try {
      // Usar URL directa en lugar de método Config
      final url = '${Config.baseUrl}/api/dashboard/ventas/tiempo-real';
      print(' URL ventas tiempo real: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: Config.defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      print(' Response status ventas tiempo real: ${response.statusCode}');
      print(' Response body ventas tiempo real: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }

      final data = json.decode(response.body);
      
      // CORREGIDO: Cambiar 'exito' por 'success'
      if (data['success'] == true) {
        final List<dynamic> rawData = data['data'] ?? [];
        return rawData.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error del servidor: ${data['message'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      print(' Error en obtenerVentasEnTiempoReal: $e');
      rethrow;
    }
  }

  // NUEVO: Obtener ventas semanales
  Future<List<Map<String, dynamic>>> obtenerVentasSemanales() async {
    try {
      final url = '${Config.baseUrl}/api/dashboard/ventas/semanales';
      print(' URL ventas semanales: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: Config.defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      print(' Response status ventas semanales: ${response.statusCode}');
      print(' Response body ventas semanales: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }

      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        final List<dynamic> rawData = data['data'] ?? [];
        return rawData.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Error del servidor: ${data['message'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      print(' Error en obtenerVentasSemanales: $e');
      rethrow;
    }
  }

  // Método de compatibilidad (opcional) - CORREGIDO
  Future<Map<String, dynamic>> obtenerEstadisticasOriginal() async {
    try {
      // Asumo que Config.getEstadisticasUrl() devuelve una URL válida
      final response = await http.get(
        Uri.parse(Config.getEstadisticasUrl()),
        headers: Config.defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);
      
      // CORREGIDO: Cambiar 'exito' por 'success'
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      } else {
        throw Exception('Error del servidor: ${data['message'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      print(' Error en obtenerEstadisticasOriginal: $e');
      rethrow;
    }
  }
}