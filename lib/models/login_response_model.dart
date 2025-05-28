// En login_response_model.dart
class LoginResponseModel {
  final bool success;
  final String message;
  final String? token;
  final UserData? data;

  LoginResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.data,
  });

  // Crear objeto desde JSON - MEJORADO CON DEBUG
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    print('LoginResponseModel.fromJson recibió:');
    print('   JSON completo: $json');
    
    // Verificar las claves disponibles
    print('Claves disponibles: ${json.keys.toList()}');
    
    // Verificar diferentes posibles estructuras
    bool success;
    String message;
    String? token;
    UserData? userData;
    
    // Determinar success
    if (json.containsKey("success")) {
      success = json["success"] == true || json["success"] == "true";
      print('   Success desde "success": $success');
    } else if (json.containsKey("mensaje")) {
      success = json["mensaje"] != null;
      print('   Success desde "mensaje": $success');
    } else {
      success = false;
      print('   Success por defecto: $success');
    }
    
    // Determinar message
    message = json["mensaje"] ?? json["message"] ?? "";
    print('   Message: "$message"');
    
    // Determinar token
    token = json["token"];
    print('   Token: ${token != null ? "${token.substring(0, 20)}..." : "null"}');
    
    // Determinar userData - AQUÍ PUEDE ESTAR EL PROBLEMA
    if (json.containsKey("usuario")) {
      print('   Encontrada clave "usuario": ${json["usuario"]}');
      userData = json["usuario"] != null ? UserData.fromJson(json["usuario"]) : null;
    } else if (json.containsKey("data")) {
      print('   Encontrada clave "data": ${json["data"]}');
      userData = json["data"] != null ? UserData.fromJson(json["data"]) : null;
    } else if (json.containsKey("user")) {
      print('   Encontrada clave "user": ${json["user"]}');
      userData = json["user"] != null ? UserData.fromJson(json["user"]) : null;
    } else {
      print('   No se encontró clave de usuario válida');
      // Intentar usar todo el json como datos de usuario si tiene campos de usuario
      if (json.containsKey("id") && json.containsKey("email")) {
        print('   Intentando usar JSON principal como datos de usuario');
        userData = UserData.fromJson(json);
      } else {
        userData = null;
      }
    }
    
    final result = LoginResponseModel(
      success: success,
      message: message,
      token: token,
      data: userData,
    );
    
    print('LoginResponseModel creado:');
    print('   - Success: ${result.success}');
    print('   - Message: "${result.message}"');
    print('   - Token: ${result.token != null ? "Presente" : "null"}');
    print('   - UserData: ${result.data != null ? "Presente" : "null"}');
    if (result.data != null) {
      print('     - Nombre: "${result.data!.nombre}"');
      print('     - Email: "${result.data!.email}"');
    }
    
    return result;
  }

  // Método toJson necesario para SharedService
  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "token": token,
      "data": data?.toJson(),
    };
  }
}

class UserData {
  final int id;
  final String email;
  final String nombre;
  final int id_rol; 
  final String? foto;
  final List<String>? permisos;

  UserData({
    required this.id,
    required this.email,
    required this.nombre,
    this.id_rol = 0,
    this.foto,
    this.permisos,
  });

  // Crear objeto desde JSON - MEJORADO CON DEBUG
  factory UserData.fromJson(Map<String, dynamic> json) {
    print('UserData.fromJson recibió: $json');
    print('Claves disponibles: ${json.keys.toList()}');
    
    // Mapear campos con múltiples posibles nombres
    int id = 0;
    String email = "";
    String nombre = "";
    int idRol = 0;
    String? foto;
    List<String>? permisos;
    
    // ID
    if (json.containsKey("id")) {
      id = json["id"] is String ? int.tryParse(json["id"]) ?? 0 : json["id"] ?? 0;
    } else if (json.containsKey("user_id")) {
      id = json["user_id"] is String ? int.tryParse(json["user_id"]) ?? 0 : json["user_id"] ?? 0;
    }
    print('   ID mapeado: $id');
    
    // Email
    email = json["email"] ?? json["correo"] ?? "";
    print('   Email mapeado: "$email"');
    
    // Nombre - múltiples posibilidades
    if (json.containsKey("nombre")) {
      nombre = json["nombre"] ?? "";
    } else if (json.containsKey("name")) {
      nombre = json["name"] ?? "";
    } else if (json.containsKey("usuario")) {
      nombre = json["usuario"] ?? "";
    } else if (json.containsKey("username")) {
      nombre = json["username"] ?? "";
    }
    print('   Nombre mapeado: "$nombre"');
    
    // ID Rol
    if (json.containsKey("id_rol")) {
      idRol = json["id_rol"] is String ? int.tryParse(json["id_rol"]) ?? 0 : json["id_rol"] ?? 0;
    } else if (json.containsKey("role_id")) {
      idRol = json["role_id"] is String ? int.tryParse(json["role_id"]) ?? 0 : json["role_id"] ?? 0;
    } else if (json.containsKey("rol")) {
      idRol = json["rol"] is String ? int.tryParse(json["rol"]) ?? 0 : json["rol"] ?? 0;
    }
    print('   ID Rol mapeado: $idRol');
    
    // Foto
    foto = json["foto"] ?? json["avatar"] ?? json["picture"];
    print('   Foto mapeada: ${foto ?? "null"}');
    
    // Permisos
    if (json["permisos"] != null) {
      permisos = List<String>.from(json["permisos"]);
    } else if (json["permissions"] != null) {
      permisos = List<String>.from(json["permissions"]);
    }
    print('   Permisos mapeados: $permisos');
    
    final result = UserData(
      id: id,
      email: email,
      nombre: nombre,
      id_rol: idRol,
      foto: foto,
      permisos: permisos,
    );
    
    print('UserData creado:');
    print('   - ID: ${result.id}');
    print('   - Email: "${result.email}"');
    print('   - Nombre: "${result.nombre}"');
    print('   - ID Rol: ${result.id_rol}');
    
    return result;
  }

  // Método toJson necesario para LoginResponseModel.toJson
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "nombre": nombre,
      "id_rol": id_rol,
      "foto": foto,
      "permisos": permisos,
    };
  }
}