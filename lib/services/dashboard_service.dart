import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_nextmeal/pages/config.dart';

class DashboardService {
  // Usar las URLs del Config
  Future<Map<String, dynamic>> obtenerResumen() async {
    try {
      final response = await http.get(
        Uri.parse(Config.getDashboardResumenUrl()),
        headers: Config.defaultHeaders,
      );

      if (Config.enableLogging) {
        print('Petición a: ${Config.getDashboardResumenUrl()}');
        print('Respuesta: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, dynamic>.from(data['data'] ?? {});
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (Config.enableLogging) {
        print('Error en obtenerResumen: $e');
      }
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerEstadisticasSemanal() async {
    try {
      final response = await http.get(
        Uri.parse(Config.getDashboardEstadisticasSemanalesUrl()),
        headers: Config.defaultHeaders,
      );

      if (Config.enableLogging) {
        print('Petición a: ${Config.getDashboardEstadisticasSemanalesUrl()}');
        print('Respuesta: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> rawData = data['data'] ?? [];
        return rawData.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (Config.enableLogging) {
        print('Error en obtenerEstadisticasSemanal: $e');
      }
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> obtenerMetodosPagoHoy() async {
    try {
      final response = await http.get(
        Uri.parse(Config.getDashboardMetodosPagoHoyUrl()),
        headers: Config.defaultHeaders,
      );

      if (Config.enableLogging) {
        print('Petición a: ${Config.getDashboardMetodosPagoHoyUrl()}');
        print('Respuesta: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, dynamic>.from(data['data'] ?? {});
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (Config.enableLogging) {
        print('Error en obtenerMetodosPagoHoy: $e');
      }
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerVentasEnTiempoReal() async {
    try {
      final response = await http.get(
        Uri.parse(Config.getDashboardVentasTiempoRealUrl()),
        headers: Config.defaultHeaders,
      );

      if (Config.enableLogging) {
        print('Petición a: ${Config.getDashboardVentasTiempoRealUrl()}');
        print('Respuesta: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> rawData = data['data'] ?? [];
        return rawData.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (Config.enableLogging) {
        print('Error en obtenerVentasEnTiempoReal: $e');
      }
      throw Exception('Error de conexión: $e');
    }
  }

  // Método para obtener estadísticas usando la API original
  Future<Map<String, dynamic>> obtenerEstadisticasOriginal() async {
    try {
      final response = await http.get(
        Uri.parse(Config.getEstadisticasUrl()),
        headers: Config.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, dynamic>.from(data);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (Config.enableLogging) {
        print('Error en obtenerEstadisticasOriginal: $e');
      }
      throw Exception('Error de conexión: $e');
    }
  }
}