import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_nextmeal/pages/config.dart';

class DashboardService {
  // Obtener resumen del dashboard
  Future<Map<String, dynamic>> obtenerResumen() async {
    try {
      final url = Config.getDashboardResumenUrl();
      if (Config.enableLogging) {
        print('📡 Petición a: $url');
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: Config.defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      if (Config.enableLogging) {
        print('📡 Respuesta: ${response.statusCode}');
        print('📡 Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['exito'] == true) {
          return Map<String, dynamic>.from(data['data'] ?? {});
        } else {
          throw Exception('Error del servidor: ${data['mensaje']}');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (Config.enableLogging) {
        print('❌ Error en obtenerResumen: $e');
      }
      rethrow; // Re-lanzar el error en lugar de usar datos falsos
    }
  }

  // Obtener estadísticas semanales
  Future<List<Map<String, dynamic>>> obtenerEstadisticasSemanal() async {
    try {
      final url = '${Config.baseUrl}/api/dashboard/estadisticas/semanal';
      if (Config.enableLogging) {
        print('📡 Petición a: $url');
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: Config.defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      if (Config.enableLogging) {
        print('📡 Respuesta: ${response.statusCode}');
        print('📡 Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['exito'] == true) {
          final List<dynamic> rawData = data['data'] ?? [];
          return rawData.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        } else {
          throw Exception('Error del servidor: ${data['mensaje']}');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (Config.enableLogging) {
        print('❌ Error en obtenerEstadisticasSemanal: $e');
      }
      rethrow;
    }
  }

  // Obtener métodos de pago de hoy
  Future<Map<String, dynamic>> obtenerMetodosPagoHoy() async {
    try {
      final url = '${Config.baseUrl}/api/dashboard/metodos-pago/hoy';
      if (Config.enableLogging) {
        print('📡 Petición a: $url');
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: Config.defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      if (Config.enableLogging) {
        print('📡 Respuesta: ${response.statusCode}');
        print('📡 Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['exito'] == true) {
          return Map<String, dynamic>.from(data['data'] ?? {});
        } else {
          throw Exception('Error del servidor: ${data['mensaje']}');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (Config.enableLogging) {
        print('❌ Error en obtenerMetodosPagoHoy: $e');
      }
      rethrow;
    }
  }

  // Obtener ventas en tiempo real
  Future<List<Map<String, dynamic>>> obtenerVentasEnTiempoReal() async {
    try {
      final url = Config.getDashboardVentasTiempoRealUrl();
      final response = await http.get(
        Uri.parse(url),
        headers: Config.defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['exito'] == true) {
          final List<dynamic> rawData = data['data'] ?? [];
          return rawData.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        } else {
          throw Exception('Error del servidor: ${data['mensaje']}');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (Config.enableLogging) {
        print('❌ Error en obtenerVentasEnTiempoReal: $e');
      }
      rethrow;
    }
  }

  // Método para obtener estadísticas usando la API original
  Future<Map<String, dynamic>> obtenerEstadisticasOriginal() async {
    try {
      final response = await http.get(
        Uri.parse(Config.getEstadisticasUrl()),
        headers: Config.defaultHeaders,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, dynamic>.from(data);
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (Config.enableLogging) {
        print('❌ Error en obtenerEstadisticasOriginal: $e');
      }
      rethrow;
    }
  }
}