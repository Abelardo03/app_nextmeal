import 'package:flutter/material.dart';
import 'package:app_nextmeal/models/login_request_model.dart';
import 'package:app_nextmeal/services/api_service.dart';
import 'package:app_nextmeal/services/shared_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool isApiCallProcess = false;
  bool hidePassword = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? correoElectronico;
  String? password;
  String? errorMessage;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    
    _animationController.forward();
    
    // Verificar si el usuario ya está logueado
    _checkLogin();
  }
  
  void _checkLogin() async {
    final isLoggedIn = await SharedService.isLoggedIn();
    if (isLoggedIn && mounted) {
      // Si está logueado, redirigir a la página principal
      // Navigator.pushReplacementNamed(context, '/home');
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Contenido principal
            Form(
              key: formKey,
              child: _loginUI(context),
            ),
            
            // Overlay de carga
            if (isApiCallProcess)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6B00),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: null, // Asegúrate de que no haya nada en el bottomNavigationBar
      ),
    );
  }

  Widget _loginUI(BuildContext context) {
    // Definir size al inicio de la función
    final Size size = MediaQuery.of(context).size;
    
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.black,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Logo section
              SizedBox(height: size.height * 0.1),
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildLogoSection(),
              ),
              
              SizedBox(height: size.height * 0.06),
              
              // Form section
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildFormSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          height: 120,
          width: 120,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFF6B00).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback si la imagen no se encuentra
              return const Icon(
                Icons.restaurant_menu,
                size: 70,
                color: Color(0xFFFF6B00),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "INGRESAR",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Error message if any
        if (errorMessage != null && errorMessage!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
              ),
            ),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        
        // Email field
        _buildInputLabel("Correo Electrónico"),
        const SizedBox(height: 10),
        _buildTextField(
          hint: "usuario@ejemplo.com",
          icon: Icons.email_outlined,
          isPassword: false,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Por favor ingrese su correo electrónico";
            }
            
            return null;
          },
          onChanged: (value) {
            setState(() {
              correoElectronico = value;
            });
          },
        ),
        
        const SizedBox(height: 25),
        
        // Password field
        _buildInputLabel("Contraseña"),
        const SizedBox(height: 10),
        _buildTextField(
          hint: "••••••••",
          icon: Icons.lock_outline,
          isPassword: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Por favor ingrese su contraseña";
            }
            if (value.length < 3) {
              return "La contraseña debe tener al menos 6 caracteres";
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              password = value;
            });
          },
        ),
        
        const SizedBox(height: 15),
        
        // Forgot password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              padding: EdgeInsets.zero,
            ),
            child: const Text(
              "",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFFF6B00),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Login button
        _buildLoginButton(),
        
        const SizedBox(height: 25),
        
        // Register option
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(10, 10),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: const Color(0xFFFF6B00),
                ),
                child: const Text(
                  "Bienvenido",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40), // Agregar espacio al final
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required bool isPassword,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextFormField(
        obscureText: isPassword && hidePassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.3),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFFF6B00),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 17,
            horizontal: 20,
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        _loginUser();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6B00),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: const Text(
        "INGRESAR",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
  
  void _loginUser() async {
    // Validar el formulario
    if (formKey.currentState!.validate()) {
      setState(() {
        isApiCallProcess = true;
        errorMessage = null;
      });
      
      try {
        // Crear modelo de solicitud de login
        LoginRequestModel model = LoginRequestModel(
          email: correoElectronico!,
          password: password!,
        );
        
        // Depuración: Imprimir información de la solicitud
        print("Intentando login con email: ${model.email}");
        print("Password length: ${model.password.length}");
        
        // Intentar login
        bool success = await APIService.login(model);
        
        // Depuración: Imprimir resultado
        print("Resultado del login: ${success ? 'Exitoso' : 'Fallido'}");
        
        if (mounted) {
          setState(() {
            isApiCallProcess = false;
          });
          
          if (success) {
            // Depuración: Verificar datos de usuario
            final userDetails = await SharedService.loginDetails();
            print("Datos de usuario obtenidos: ${userDetails != null}");
            if (userDetails != null) {
              print("Token: ${userDetails.token?.substring(0, 10)}...");
              print("Usuario: ${userDetails.data?.nombre}");
            }
            
            // Login exitoso, redirigir a la página principal
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            setState(() {
              errorMessage = "Credenciales inválidas. Por favor, intente de nuevo.";
            });
          }
        }
      } catch (e) {
        // Depuración: Imprimir excepción detallada
        print("Excepción en _loginUser: $e");
        print("Stack trace: ${StackTrace.current}");
        
        if (mounted) {
          setState(() {
            isApiCallProcess = false;
            errorMessage = "Error de conexión: $e";
          });
        }
      }
    }
  }
}