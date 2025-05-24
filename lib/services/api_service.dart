import "dart:convert";

import "package:app_nextmeal/models/login_request_model.dart";
import "package:app_nextmeal/models/login_response_model.dart";
import 'package:app_nextmeal/models/venta_model.dart'; 
import "package:app_nextmeal/pages/config.dart";
import "package:app_nextmeal/services/shared_service.dart"; // Importación agregada
import "package:http/http.dart" as http;

class APIService {
  static var client = http.Client();

  static Future<bool> login(LoginRequestModel models) async {
    Map<String, String> requestHeaders = {
      "Content-Type": "application/json"
    };
    var url = Uri.http(Config.apiurl, Config.loginapi);
    
    try {
      print("Enviando solicitud a: ${url.toString()}");
      print("Datos: ${jsonEncode(models.toJson())}");
      
      var response = await client.post(
        url,
        headers: requestHeaders, 
        body: jsonEncode(models.toJson()),
      );
      
      print("Código de estado: ${response.statusCode}");
      print("Respuesta: ${response.body}");
      
      if(response.statusCode == 200) {
        // Corregido: Decodificar JSON y usar LoginResponseModel.fromJson
        final responseData = jsonDecode(response.body);
        final loginResponse = LoginResponseModel.fromJson(responseData);
        
        await SharedService.setLoginDetails(loginResponse);
        return true;
      } else {
        // Manejar diferentes códigos de error
        print("Error en login: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Excepción en login: $e");
      return false;
    }
  }

  // Método para obtener todas las ventas
  static Future<List<Venta>> getVentas() async {
    var loginDetails = await SharedService.loginDetails();
    
    if (loginDetails == null) {
      throw Exception("No hay sesión activa");
    }

    Map<String, String> requestHeaders = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${loginDetails.token}"
    };

    var url = Uri.http(Config.apiurl, Config.ventasapi);
    
    try {
      print("Obteniendo ventas desde: ${url.toString()}");
      
      var response = await client.get(
        url,
        headers: requestHeaders,
      ).timeout(const Duration(seconds: 30));
      
      print("Código de estado: ${response.statusCode}");
      
      if(response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((json) => Venta.fromJson(json)).toList();
      } else {
        print("Error al obtener ventas: ${response.statusCode} - ${response.body}");
        throw Exception("Error al obtener ventas: ${response.statusCode}");
      }
    } catch (e) {
      print("Excepción al obtener ventas: $e");
      throw Exception("Error de conexión: $e");
    }
  }
}