import 'dart:convert';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:app_nextmeal/models/login_response_model.dart';
import 'package:flutter/material.dart';

class SharedService {
  static Future<bool> isLoggedIn() async {
    var isKeyExist = 
      await APICacheManager().isAPICacheKeyExist("login_details"); 
   
    return isKeyExist;
  }

  static Future<LoginResponseModel?> loginDetails() async {
    var isKeyExist = 
      await APICacheManager().isAPICacheKeyExist("login_details"); 
   
    if(isKeyExist) {
      var cacheData = await APICacheManager().getCacheData("login_details");
      
      return LoginResponseModel.fromJson(
        jsonDecode(cacheData.syncData)
      );
    }
    return null;
  }

  static Future<void> setLoginDetails(LoginResponseModel model) async {
    APICacheDBModel cacheModel = APICacheDBModel(
      key: "login_details", 
      syncData: jsonEncode(model.toJson()),
    ); 
    await APICacheManager().addCacheData(cacheModel);
  }

  // Clear login data only
  static Future<void> clearLoginData() async {
    await APICacheManager().deleteCache("login_details");
  }

  // Full logout with navigation (requires context)
  static Future<void> logout(BuildContext context) async {
    await clearLoginData();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false
    );
  }
}