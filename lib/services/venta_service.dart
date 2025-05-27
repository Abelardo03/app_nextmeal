import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_nextmeal/pages/config.dart';
import 'package:app_nextmeal/services/shared_service.dart';
import 'package:app_nextmeal/models/venta_model.dart';
import 'package:api_cache_manager/api_cache_manager.dart';

class VentaService {
  static var client = http.Client();

  static Future<String?> _getToken() async {
    final loginDetails = await SharedService.loginDetails();
    return loginDetails?.token;
  }

  static Future<List<Venta>> obtenerVentas() async {
    try {
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación');
      }

      final url = Uri.http(Config.apiurl, Config.ventasapi);
      
      print('Obteniendo ventas desde: ${url.toString()}');
      
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('Status code ventas: ${response.statusCode}');
      print('Response body ventas: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        
        print('Tipo de responseData: ${responseData.runtimeType}'); // Debug adicional
        
        // ✅ Manejar la respuesta de tu API específicamente
        if (responseData is Map<String, dynamic>) {
          // Verificar si tiene éxito
          if (responseData['exito'] == true && responseData.containsKey('data')) {
            final dynamic data = responseData['data'];
            if (data is List) {
              print('Encontradas ${data.length} ventas'); // Debug
              return data.map((json) => Venta.fromJson(json)).toList();
            } else {
              throw Exception('El campo "data" no es una lista');
            }
          } else {
            throw Exception('Respuesta sin éxito o sin campo "data"');
          }
        } else if (responseData is List) {
          // Por si acaso viene directamente como lista
          return responseData.map((json) => Venta.fromJson(json)).toList();
        } else {
          throw Exception('Formato de respuesta no válido: ${responseData.runtimeType}');
        }
      } else if (response.statusCode == 401) {
        await APICacheManager().deleteCache("login_details");
        throw Exception('Sesión expirada. Inicie sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para ver las ventas');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerVentas: $e');
      rethrow;
    }
  }

  static Future<Venta?> obtenerVentaPorId(int id) async {
    try {
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación');
      }

      final url = Uri.http(Config.apiurl, '${Config.ventasapi}/$id');
      
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        return Venta.fromJson(responseData);
      } else if (response.statusCode == 401) {
        await APICacheManager().deleteCache("login_details");
        throw Exception('Sesión expirada. Inicie sesión nuevamente.');
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerVentaPorId: $e');
      rethrow;
    }
  }

  static Future<Venta> crearVenta({
    required int idPedido,
    required String metodoPago,
  }) async {
    try {
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación');
      }

      final url = Uri.http(Config.apiurl, Config.ventasapi);
      
      final body = {
        'id_pedido': idPedido,
        'metodo_pago': metodoPago,
      };

      print('Creando venta: ${jsonEncode(body)}');

      final response = await client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print('Response crear venta: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        return Venta.fromJson(responseData);
      } else if (response.statusCode == 401) {
        await APICacheManager().deleteCache("login_details");
        throw Exception('Sesión expirada. Inicie sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para crear ventas');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['mensaje'] ?? 'Datos inválidos');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en crearVenta: $e');
      rethrow;
    }
  }

  static Future<Venta> actualizarMetodoPago({
    required int id,
    required String metodoPago,
  }) async {
    try {
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación');
      }

      final url = Uri.http(Config.apiurl, '${Config.ventasapi}/$id/metodo-pago');
      
      final body = {
        'metodo_pago': metodoPago,
      };

      print('Actualizando método de pago: ${jsonEncode(body)}');

      final response = await client.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        return Venta.fromJson(responseData);
      } else if (response.statusCode == 401) {
        await APICacheManager().deleteCache("login_details");
        throw Exception('Sesión expirada. Inicie sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para editar ventas');
      } else if (response.statusCode == 404) {
        throw Exception('Venta no encontrada');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['mensaje'] ?? 'Error del servidor');
      }
    } catch (e) {
      print('Error en actualizarMetodoPago: $e');
      rethrow;
    }
  }

  static Future<bool> eliminarVenta(int id) async {
    try {
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación');
      }

      final url = Uri.http(Config.apiurl, '${Config.ventasapi}/$id');
      
      final response = await client.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // ✅ Fixed: Use clearLoginData instead of logout
        await SharedService.clearLoginData();
        throw Exception('Sesión expirada. Inicie sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para eliminar ventas (solo administradores)');
      } else if (response.statusCode == 404) {
        throw Exception('Venta no encontrada');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en eliminarVenta: $e');
      rethrow;
    }
  }
}