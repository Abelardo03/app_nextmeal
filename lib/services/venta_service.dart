import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_nextmeal/models/venta_model.dart';
import 'package:app_nextmeal/pages/config.dart';

class VentaService {
  // Token de autenticación - esto debería venir del sistema de login
  static String? _authToken;
  
  // TEMPORAL: Para testing sin autenticación
  static bool _usarDatosPrueba = false;
  
  // Método para establecer el token (llamar después del login)
  static void setAuthToken(String token) {
    _authToken = token;
    _usarDatosPrueba = false;
  }
  
  // Método para testing - forzar uso de API sin token
  static void configurarTesting({bool usarDatosPrueba = false}) {
    _usarDatosPrueba = usarDatosPrueba;
  }
  
  // Headers con autenticación
  static Map<String, String> get _authHeaders => {
    ...Config.defaultHeaders,
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  static Future<List<Venta>> obtenerVentas() async {
    try {
      // Si está configurado para usar datos de prueba
      if (_usarDatosPrueba) {
        if (Config.enableLogging) {
          print('Usando datos de prueba (configuración de testing)');
        }
        return _obtenerVentasPrueba();
      }

      // Intentar conectar con la API real
      final response = await http.get(
        Uri.parse(Config.getVentasUrl()),
        headers: _authHeaders,
      ).timeout(const Duration(seconds: 10));

      if (Config.enableLogging) {
        print('🌐 Petición a: ${Config.getVentasUrl()}');
        print('📤 Headers enviados: $_authHeaders');
        print('📥 Respuesta: ${response.statusCode}');
        print('📄 Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['exito'] == true && data['data'] != null) {
          final List<dynamic> ventasJson = data['data'];
          
          if (Config.enableLogging) {
            print('✅ Ventas cargadas desde API: ${ventasJson.length}');
          }
          
          return ventasJson.map((json) => Venta.fromJson(json)).toList();
        } else {
          throw Exception('Respuesta inválida del servidor: ${data['mensaje'] ?? 'Sin mensaje'}');
        }
      } else if (response.statusCode == 401) {
        // Token inválido o expirado
        _authToken = null;
        throw Exception('❌ Error 401: Acceso denegado. Se requiere autenticación.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception('❌ Error ${response.statusCode}: ${errorData['mensaje'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      if (Config.enableLogging) {
        print('❌ Error en obtenerVentas: $e');
      }
      
      // Si es error de autenticación, no usar datos de prueba
      if (e.toString().contains('401') || e.toString().contains('Acceso denegado')) {
        rethrow;
      }
      
      // Para otros errores (conexión, etc.), usar datos de prueba como fallback
      if (Config.enableLogging) {
        print('🔄 Usando datos de prueba como fallback debido a error de conexión');
      }
      return _obtenerVentasPrueba();
    }
  }

  static Future<Venta> obtenerVentaPorId(int id) async {
    try {
      if (_usarDatosPrueba) {
        return _obtenerVentasPrueba().then((ventas) => 
          ventas.firstWhere((v) => v.id == id, orElse: () => ventas.first)
        );
      }

      final response = await http.get(
        Uri.parse('${Config.getVentasUrl()}/$id'),
        headers: _authHeaders,
      ).timeout(const Duration(seconds: 10));

      if (Config.enableLogging) {
        print('🌐 Petición a: ${Config.getVentasUrl()}/$id');
        print('📥 Respuesta: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['exito'] == true && data['data'] != null) {
          return Venta.fromJson(data['data']);
        } else {
          throw Exception('Venta no encontrada');
        }
      } else if (response.statusCode == 401) {
        _authToken = null;
        throw Exception('❌ Error 401: Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception('❌ Error ${response.statusCode}: ${errorData['mensaje'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      if (Config.enableLogging) {
        print('❌ Error en obtenerVentaPorId: $e');
      }
      
      if (e.toString().contains('401') || e.toString().contains('Sesión expirada')) {
        rethrow;
      }
      
      // Fallback a datos de prueba
      final ventas = await _obtenerVentasPrueba();
      return ventas.firstWhere((v) => v.id == id, orElse: () => ventas.first);
    }
  }

  // Método para probar la conexión con el backend
  static Future<bool> probarConexion() async {
    try {
      final response = await http.get(
        Uri.parse(Config.getVentasUrl()),
        headers: _authHeaders,
      ).timeout(const Duration(seconds: 5));
      
      if (Config.enableLogging) {
        print('🔍 Prueba de conexión: ${response.statusCode}');
        print('📄 Respuesta: ${response.body}');
      }
      
      return response.statusCode == 200 || response.statusCode == 401;
    } catch (e) {
      if (Config.enableLogging) {
        print('❌ Error de conexión: $e');
      }
      return false;
    }
  }

  static Future<bool> crearVenta({
    required int idPedido,
    required String metodoPago,
  }) async {
    try {
      if (_authToken == null) {
        throw Exception('Debes iniciar sesión para crear ventas');
      }

      final ventaData = {
        'id_pedido': idPedido,
        'metodo_pago': metodoPago.toLowerCase(),
      };

      final response = await http.post(
        Uri.parse(Config.getVentasUrl()),
        headers: _authHeaders,
        body: json.encode(ventaData),
      );

      if (Config.enableLogging) {
        print('Creando venta: $ventaData');
        print('Respuesta: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['exito'] == true;
      } else if (response.statusCode == 401) {
        _authToken = null;
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['mensaje'] ?? 'Error al crear la venta');
      }
    } catch (e) {
      if (Config.enableLogging) {
        print('Error en crearVenta: $e');
      }
      rethrow;
    }
  }

  static Future<bool> actualizarMetodoPago(int id, String metodoPago) async {
    try {
      if (_authToken == null) {
        throw Exception('Debes iniciar sesión para actualizar ventas');
      }

      final ventaData = {
        'metodo_pago': metodoPago.toLowerCase(),
      };

      final response = await http.put(
        Uri.parse('${Config.getVentasUrl()}/$id/metodo-pago'),
        headers: _authHeaders,
        body: json.encode(ventaData),
      );

      if (Config.enableLogging) {
        print('Actualizando método de pago: $ventaData');
        print('Respuesta: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exito'] == true;
      } else if (response.statusCode == 401) {
        _authToken = null;
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['mensaje'] ?? 'Error al actualizar la venta');
      }
    } catch (e) {
      if (Config.enableLogging) {
        print('Error en actualizarMetodoPago: $e');
      }
      rethrow;
    }
  }

  // Datos de prueba para cuando no hay conexión o autenticación
  static Future<List<Venta>> _obtenerVentasPrueba() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    return [
      Venta(
        id: 1001,
        nombreCliente: 'María González',
        fecha: DateTime.now().subtract(const Duration(hours: 2)),
        total: 45000.0,
        metodoPago: 'efectivo',
      ),
      Venta(
        id: 1002,
        nombreCliente: 'Carlos Rodríguez',
        fecha: DateTime.now().subtract(const Duration(hours: 4)),
        total: 32500.0,
        metodoPago: 'transferencia',
      ),
      Venta(
        id: 1003,
        nombreCliente: 'Ana Martínez',
        fecha: DateTime.now().subtract(const Duration(hours: 6)),
        total: 78000.0,
        metodoPago: 'efectivo',
      ),
      Venta(
        id: 1004,
        nombreCliente: 'Luis Fernández',
        fecha: DateTime.now().subtract(const Duration(days: 1)),
        total: 25000.0,
        metodoPago: 'transferencia',
      ),
      Venta(
        id: 1005,
        nombreCliente: 'Patricia Silva',
        fecha: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        total: 56000.0,
        metodoPago: 'efectivo',
      ),
    ];
  }

  // Método para filtrar ventas localmente
  static Future<List<Venta>> obtenerVentasConFiltros({
    String? metodoPago,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? busqueda,
  }) async {
    try {
      List<Venta> todasLasVentas = await obtenerVentas();
      
      // Aplicar filtros
      List<Venta> ventasFiltradas = todasLasVentas;
      
      if (metodoPago != null && metodoPago != 'Todos los métodos') {
        ventasFiltradas = ventasFiltradas.where(
          (venta) => venta.metodoPago.toLowerCase() == metodoPago.toLowerCase()
        ).toList();
      }
      
      if (busqueda != null && busqueda.isNotEmpty) {
        ventasFiltradas = ventasFiltradas.where((venta) =>
          venta.nombreCliente.toLowerCase().contains(busqueda.toLowerCase()) ||
          venta.id.toString().contains(busqueda)
        ).toList();
      }
      
      if (fechaInicio != null) {
        ventasFiltradas = ventasFiltradas.where(
          (venta) => venta.fecha.isAfter(fechaInicio.subtract(const Duration(days: 1)))
        ).toList();
      }
      
      if (fechaFin != null) {
        ventasFiltradas = ventasFiltradas.where(
          (venta) => venta.fecha.isBefore(fechaFin.add(const Duration(days: 1)))
        ).toList();
      }
      
      return ventasFiltradas;
    } catch (e) {
      if (Config.enableLogging) {
        print('Error en obtenerVentasConFiltros: $e');
      }
      rethrow;
    }
  }
}
