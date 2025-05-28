import 'dart:convert';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:app_nextmeal/models/login_response_model.dart';
import 'package:flutter/material.dart';

class SharedService {
  static Future<bool> isLoggedIn() async {
    var isKeyExist = 
      await APICacheManager().isAPICacheKeyExist("login_details"); 
   
    print('SharedService.isLoggedIn(): $isKeyExist');
    return isKeyExist;
  }

  static Future<LoginResponseModel?> loginDetails() async {
    try {
      var isKeyExist = 
        await APICacheManager().isAPICacheKeyExist("login_details"); 
      
      print('SharedService.loginDetails() - Key exists: $isKeyExist');
      
      if(isKeyExist) {
        var cacheData = await APICacheManager().getCacheData("login_details");
        
        print('Datos RAW del cache: ${cacheData.syncData}');
        
        // Decodificar y mostrar los datos
        var jsonData = jsonDecode(cacheData.syncData);
        print('JSON decodificado completo: $jsonData');
        
        // DEBUG DETALLADO: Verificar la estructura exacta
        print('ESTRUCTURA DEL JSON:');
        jsonData.forEach((key, value) {
          print('   - $key: $value (${value.runtimeType})');
          if (value is Map) {
            print('     Subestructura de $key:');
            value.forEach((subKey, subValue) {
              print('       - $subKey: $subValue (${subValue.runtimeType})');
            });
          }
        });
        
        var loginResponse = LoginResponseModel.fromJson(jsonData);
        
        // Debug de los datos del modelo
        print('Modelo creado:');
        print('   - Success: ${loginResponse.success}');
        print('   - Message: ${loginResponse.message}');
        print('   - Token: ${loginResponse.token?.substring(0, 20) ?? 'null'}...');
        print('   - Data is null: ${loginResponse.data == null}');
        if (loginResponse.data != null) {
          print('   - Nombre: "${loginResponse.data!.nombre}"');
          print('   - Email: "${loginResponse.data!.email}"');
          print('   - ID: ${loginResponse.data!.id}');
          print('   - ID_ROL: ${loginResponse.data!.id_rol}');
          print('   - Foto: ${loginResponse.data!.foto}');
        } else {
          print('   ERROR - DATA ES NULL - Verificar mapeo en LoginResponseModel.fromJson');
        }
        
        return loginResponse;
      }
      
      print('No hay datos de login en cache');
      return null;
    } catch (e, stackTrace) {
      print('Error en SharedService.loginDetails(): $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<void> setLoginDetails(LoginResponseModel model) async {
    try {
      print('Guardando detalles de login...');
      print('Modelo ORIGINAL a guardar:');
      print('   - Success: ${model.success}');
      print('   - Message: "${model.message}"');
      print('   - Token: ${model.token?.substring(0, 20) ?? 'null'}...');
      print('   - Data is null: ${model.data == null}');
      if (model.data != null) {
        print('   - Nombre: "${model.data!.nombre}"');
        print('   - Email: "${model.data!.email}"');
        print('   - ID: ${model.data!.id}');
        print('   - ID_ROL: ${model.data!.id_rol}');
      }
      
      var jsonString = jsonEncode(model.toJson());
      print('JSON final a guardar: $jsonString');
      
      APICacheDBModel cacheModel = APICacheDBModel(
        key: "login_details", 
        syncData: jsonString,
      ); 
      
      await APICacheManager().addCacheData(cacheModel);
      print('Datos guardados correctamente en cache');
      
      // Verificación inmediata
      var verification = await loginDetails();
      print('Verificación inmediata:');
      if (verification?.data != null) {
        print('   Nombre verificado: "${verification!.data!.nombre}"');
        print('   Email verificado: "${verification.data!.email}"');
      } else {
        print('   Error en verificación - datos no recuperables');
      }
      
    } catch (e, stackTrace) {
      print('Error al guardar detalles de login: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // Clear login data only
  static Future<void> clearLoginData() async {
    try {
      print('Eliminando datos de login...');
      await APICacheManager().deleteCache("login_details");
      print('Datos eliminados correctamente');
    } catch (e) {
      print('Error al eliminar datos de login: $e');
    }
  }

  // Full logout with navigation (requires context)
  static Future<void> logout(BuildContext context) async {
    print('Iniciando logout...');
    await clearLoginData();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false
    );
    print('Logout completado');
  }
}