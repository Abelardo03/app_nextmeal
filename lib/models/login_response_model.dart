// En login_response_model.dart
class LoginResponseModel {
  final bool success;
  final String message;
  final String? token;
  final UserData? data;

  // Corregido: Renombrado a LoginResponseModel
  LoginResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.data,
  });

  // Crear objeto desde JSON
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Adaptación para manejar la respuesta del servidor
    return LoginResponseModel(
      success: json["mensaje"] != null, // Si hay mensaje, consideramos éxito
      message: json["mensaje"] ?? "",
      token: json["token"],
      data: json["usuario"] != null ? UserData.fromJson(json["usuario"]) : null,
    );
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
  final List<String>? permisos; // Agregado para manejar permisos

  UserData({
    required this.id,
    required this.email,
    required this.nombre,
    this.id_rol = 0,
    this.foto,
    this.permisos,
  });

  // Crear objeto desde JSON
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json["id"] ?? "",
      email: json["email"] ?? "",
      nombre: json["nombre"] ?? "", // Cambiado para coincidir con el backend
      id_rol: json["id_rol"], // Convertido a string si es necesario
      foto: json["foto"],
      permisos: json["permisos"] != null 
        ? List<String>.from(json["permisos"]) 
        : null,
    );
  }

  // Método toJson necesario para LoginResponseModel.toJson
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "nombre": nombre,
      "rol": id_rol,
      "foto": foto,
      "permisos": permisos,
    };
  }
}