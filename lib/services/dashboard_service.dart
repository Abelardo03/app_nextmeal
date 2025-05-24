import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:app_nextmeal/models/venta_model.dart';
import 'package:app_nextmeal/pages/config.dart';

class DashboardService {
  // URL base de la API usando la configuración
  final String _baseUrl = Config.apiurl.startsWith('http')
      ? Config.apiurl
      : 'http://${Config.apiurl}';

  // Obtener resumen del dashboard
  Future<Map<String, dynamic>> obtenerResumen() async {
    try {
      print(
          'Solicitando datos de resumen a: $_baseUrl${Config.estadisticasapi}/resumen');

      final response = await http.get(
        Uri.parse('$_baseUrl${Config.estadisticasapi}/resumen'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('Respuesta del servidor (resumen): ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['exito'] == true) {
            return responseData['data'] ??
                {
                  'totalVentas': 0,
                  'montoTotal': 0,
                  'promedioVenta': 0,
                  'ventasHoy': 0,
                  'montoVentasHoy': 0,
                  'metodoPago': {
                    'efectivo': 0,
                    'transferencia': 0,
                  }
                };
          } else {
            throw Exception(
                responseData['mensaje'] ?? 'Error al obtener resumen');
          }
        } catch (e) {
          print('Error al decodificar JSON de resumen: $e');
          return {
            'totalVentas': 0,
            'montoTotal': 0,
            'promedioVenta': 0,
            'ventasHoy': 0,
            'montoVentasHoy': 0,
            'metodoPago': {
              'efectivo': 0,
              'transferencia': 0,
            }
          };
        }
      } else {
        throw Exception('Error al obtener resumen: ${response.statusCode}');
      }
    } catch (e) {
      print('Error general al obtener resumen: $e');
      return {
        'totalVentas': 0,
        'montoTotal': 0,
        'promedioVenta': 0,
        'ventasHoy': 0,
        'montoVentasHoy': 0,
        'metodoPago': {
          'efectivo': 0,
          'transferencia': 0,
        }
      };
    }
  }

  // Obtener ventas recientes
  Future<List<Venta>> obtenerVentasRecientes() async {
    try {
      print(
          'Solicitando ventas recientes a: $_baseUrl${Config.estadisticasapi}/ventas-recientes');

      final response = await http.get(
        Uri.parse('$_baseUrl${Config.estadisticasapi}/ventas-recientes'),
        headers: {'Content-Type': 'application/json'},
      );

      print(
          'Respuesta del servidor (ventas recientes): ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['exito'] == true) {
          final List<dynamic> ventasData = responseData['data'] ?? [];
          return ventasData
              .map((ventaJson) => Venta.fromJson(ventaJson))
              .toList();
        } else {
          throw Exception(
              responseData['mensaje'] ?? 'Error al obtener ventas recientes');
        }
      } else {
        throw Exception(
            'Error al obtener ventas recientes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerVentasRecientes: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estadísticas por período (diario, semanal, mensual)
  Future<List<Map<String, dynamic>>> obtenerEstadisticasPorPeriodo(
      String periodo) async {
    try {
      print(
          'Solicitando estadísticas por período a: $_baseUrl${Config.estadisticasapi}/estadisticas/$periodo');

      final response = await http.get(
        Uri.parse('$_baseUrl${Config.estadisticasapi}/estadisticas/$periodo'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('Respuesta del servidor (estadísticas): ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['exito'] == true) {
            final List<dynamic> estadisticasData = responseData['data'] ?? [];

            // Asegurarse de que los datos estén ordenados por día de la semana
            if (estadisticasData.isNotEmpty &&
                estadisticasData.first is Map &&
                estadisticasData.first.containsKey('día')) {
              estadisticasData.sort((a, b) {
                // Verificar que los valores de 'día' existan antes de intentar compararlos
                int diaA = a.containsKey('día') ? _getDayNumber(a['día']) : 0;
                int diaB = b.containsKey('día') ? _getDayNumber(b['día']) : 0;
                return diaA.compareTo(diaB);
              });
            }

            return estadisticasData.cast<Map<String, dynamic>>();
          } else {
            throw Exception(
                responseData['mensaje'] ?? 'Error al obtener estadísticas');
          }
        } catch (e) {
          print('Error al procesar datos de estadísticas: $e');
          // Devolver lista vacía en caso de error en el procesamiento de datos
          return [];
        }
      } else {
        throw Exception(
            'Error al obtener estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerEstadisticasPorPeriodo: $e');
      // Devolver lista vacía en caso de error
      return [];
    }
  }

  // Función auxiliar para convertir nombre de día de la semana a número
  int _getDayNumber(dynamic dia) {
    if (dia is int) return dia;

    if (dia is String) {
      const dias = {
        'lunes': 1,
        'monday': 1,
        'martes': 2,
        'tuesday': 2,
        'miércoles': 3,
        'wednesday': 3,
        'jueves': 4,
        'thursday': 4,
        'viernes': 5,
        'friday': 5,
        'sábado': 6,
        'saturday': 6,
        'domingo': 7,
        'sunday': 7,
      };
      return dias[dia.toLowerCase()] ??
          1; // Si no se encuentra, devolver 1 (lunes)
    }

    return 1; // valor por defecto
  }

  // Implementación del método _completarSemanas que faltaba
  List<Map<String, dynamic>> _completarSemanas(List<Map<String, dynamic>> datos) {
    if (datos.isEmpty) {
      return [];
    }

    // Obtener la fecha más reciente de los datos
    final fechaMasReciente = datos.isNotEmpty 
        ? DateTime.parse(datos.last['fecha'])
        : DateTime.now();
    
    // Calcular el inicio de la semana (lunes)
    final inicioSemana = fechaMasReciente.subtract(Duration(days: fechaMasReciente.weekday - 1));
    
    // Lista para almacenar los resultados completados
    final List<Map<String, dynamic>> semanaCompleta = [];
    
    // Crear un mapa para acceder rápidamente a los datos por fecha
    final Map<String, Map<String, dynamic>> datosPorFecha = {};
    for (var dato in datos) {
      final fecha = dato['fecha'];
      datosPorFecha[fecha] = dato;
    }
    
    // Completar datos para los 7 días de la semana
    for (int i = 0; i < 7; i++) {
      final fecha = inicioSemana.add(Duration(days: i));
      final fechaStr = DateFormat('yyyy-MM-dd').format(fecha);
      
      if (datosPorFecha.containsKey(fechaStr)) {
        semanaCompleta.add(datosPorFecha[fechaStr]!);
      } else {
        // Crear un día con valores en cero si no hay datos
        semanaCompleta.add({
          'fecha': fechaStr,
          'monto': 0,
          'ventas': 0,
        });
      }
    }
    
    return semanaCompleta;
  }

  Future<List<Map<String, dynamic>>> obtenerEstadisticasDiarias() async {
    try {
      print('Solicitando estadísticas diarias a: $_baseUrl${Config.estadisticasapi}/diario');
      
      final response = await http.get(
        Uri.parse('$_baseUrl${Config.estadisticasapi}/diario'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('Respuesta del servidor (estadísticas diarias): ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['exito'] == true) {
            final List<dynamic> estadisticasData = responseData['data'] ?? [];
            
            // Si no hay datos, devolver una semana completa con valores en cero
            if (estadisticasData.isEmpty) {
              return _crearSemanaPorDefecto();
            }
            
            // Convertir la lista de datos en una lista de mapas y mapear 'cantidad' a 'ventas' si existe
            final List<Map<String, dynamic>> estadisticas = 
                estadisticasData.map((item) {
                  final Map<String, dynamic> mapaItem = Map<String, dynamic>.from(item as Map<String, dynamic>);
                  
                  // Si el item tiene 'cantidad' pero no 'ventas', copiar el valor
                  if (mapaItem.containsKey('cantidad') && !mapaItem.containsKey('ventas')) {
                    mapaItem['ventas'] = mapaItem['cantidad'];
                  }
                  
                  return mapaItem;
                }).toList();
            
            // Ordenar por fecha
            estadisticas.sort((a, b) => 
                DateTime.parse(a['fecha']).compareTo(DateTime.parse(b['fecha'])));
            
            // Completar la semana con días faltantes
            return _completarSemanas(estadisticas);
          } else {
            print('Error en la respuesta: ${responseData['mensaje'] ?? 'Error desconocido'}');
            return _crearSemanaPorDefecto();
          }
        } catch (e) {
          print('Error al procesar los datos: $e');
          return _crearSemanaPorDefecto();
        }
      } else {
        print('Error HTTP: ${response.statusCode}');
        return _crearSemanaPorDefecto();
      }
    } catch (e) {
      print('Error general en obtenerEstadisticasDiarias: $e');
      return _crearSemanaPorDefecto();
    }
  }
  
  // Método para crear una semana por defecto con valores en cero
  List<Map<String, dynamic>> _crearSemanaPorDefecto() {
    final List<Map<String, dynamic>> semana = [];
    final ahora = DateTime.now();
    final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
    
    for (int i = 0; i < 7; i++) {
      final fecha = inicioSemana.add(Duration(days: i));
      semana.add({
        'fecha': DateFormat('yyyy-MM-dd').format(fecha),
        'monto': 0,
        'ventas': 0,
      });
    }
    
    return semana;
  }
}