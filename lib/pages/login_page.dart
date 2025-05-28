import 'package:flutter/material.dart';
import 'package:app_nextmeal/models/login_request_model.dart';
import 'package:app_nextmeal/services/api_service.dart';
import 'package:app_nextmeal/services/shared_service.dart';
import 'package:app_nextmeal/pages/config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool isApiCallProcess = false;
  bool hidePassword = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? correoElectronico;
  String? password;
  String? errorMessage;
  
  // Animation controllers
  late AnimationController _mainAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _particleAnimationController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Main animation controller
    _mainAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    // Pulse animation for logo
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    // Particle animation
    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particleAnimationController,
        curve: Curves.linear,
      ),
    );
    
    // Start animations
    _mainAnimationController.forward();
    _pulseAnimationController.repeat(reverse: true);
    _particleAnimationController.repeat();
    
    // Check login status
    _checkLogin();
  }
  
  void _checkLogin() async {
    final isLoggedIn = await SharedService.isLoggedIn();
    if (isLoggedIn && mounted) {
      // Navigator.pushReplacementNamed(context, '/home');
    }
  }
  
  @override
  void dispose() {
    _mainAnimationController.dispose();
    _pulseAnimationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(Config.colors['background']!),
      body: Stack(
        children: [
          // Animated background particles
          _buildAnimatedBackground(),
          
          // Main content
          SafeArea(
            child: Form(
              key: formKey,
              child: _buildMainContent(context),
            ),
          ),
          
          // Loading overlay
          if (isApiCallProcess) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.5,
              colors: [
                Color(Config.colors['surface']!),
                Color(Config.colors['background']!),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Floating geometric shapes
              Positioned(
                top: 100 + (_particleAnimation.value * 20),
                right: 50,
                child: Transform.rotate(
                  angle: _particleAnimation.value * 2,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(Config.colors['primary']!).withOpacity(0.1),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 200 - (_particleAnimation.value * 30),
                left: 30,
                child: Transform.rotate(
                  angle: -_particleAnimation.value * 1.5,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(Config.colors['secondary']!).withOpacity(0.1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              // Grid pattern overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: GridPainter(
                    color: Colors.white.withOpacity(0.02),
                    animationValue: _particleAnimation.value,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 1),
          
          // Logo and title section
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildHeaderSection(),
            ),
          ),
          
          const Spacer(flex: 1),
          
          // Form section
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildFormSection(),
            ),
          ),
          
          const Spacer(flex: 2),
          
          // Footer
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildFooter(),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        // Animated logo container
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(Config.colors['primary']!),
                      Color(Config.colors['accent']!),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Color(Config.colors['primary']!).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.analytics,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 32),
        
        // Title and subtitle
        Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Color(Config.colors['primary']!), 
                  Color(Config.colors['accent']!)
                ],
              ).createShader(bounds),
              child: const Text(
                "NEXTMEAL",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Panel de estadísticas y ventas",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Color(Config.colors['surface']!).withOpacity(0.8),
        borderRadius: BorderRadius.circular(Config.uiConfig['borderRadius']),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error message
          if (errorMessage != null && errorMessage!.isNotEmpty)
            _buildErrorMessage(),
          
          // Email field
          _buildModernTextField(
            label: "Correo Electrónico",
            hint: "admin@nextmeal.com",
            icon: Icons.alternate_email,
            isPassword: false,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Ingrese su correo electrónico";
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return "Formato de correo inválido";
              }
              return null;
            },
            onChanged: (value) => correoElectronico = value,
          ),
          
          const SizedBox(height: 24),
          
          // Password field
          _buildModernTextField(
            label: "Contraseña",
            hint: "••••••••••",
            icon: Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Ingrese su contraseña";
              }
              if (value.length < 3) {
                return "La contraseña debe tener al menos 3 caracteres";
              }
              return null;
            },
            onChanged: (value) => password = value,
          ),
          
          const SizedBox(height: 32),
          
          // Login button
          _buildModernButton(),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Color(Config.colors['error']!).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(Config.colors['error']!).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Color(Config.colors['error']!),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(
                color: Color(Config.colors['error']!),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required String hint,
    required IconData icon,
    required bool isPassword,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Color(Config.colors['background']!),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextFormField(
            obscureText: isPassword && hidePassword,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(Config.colors['primary']!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Color(Config.colors['primary']!),
                  size: 20,
                ),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white.withOpacity(0.6),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              errorStyle: TextStyle(
                color: Color(Config.colors['error']!),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            onChanged: onChanged,
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildModernButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(Config.colors['primary']!),
            Color(Config.colors['accent']!),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(Config.colors['primary']!).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _loginUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.trending_up,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Text(
              "ACCEDER AL PANEL",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(Config.colors['surface']!),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Color(Config.colors['primary']!),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Verificando credenciales...",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "NEXTMEAL",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "Sistema de análisis de ventas y estadísticas",
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  void _loginUser() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isApiCallProcess = true;
        errorMessage = null;
      });
      
      try {
        LoginRequestModel model = LoginRequestModel(
          email: correoElectronico!,
          password: password!,
        );
        
        print("Intentando login con email: ${model.email}");
        print("Password length: ${model.password.length}");
        
        bool success = await APIService.login(model);
        
        print("Resultado del login: ${success ? 'Exitoso' : 'Fallido'}");
        
        if (mounted) {
          setState(() {
            isApiCallProcess = false;
          });
          
          if (success) {
            final userDetails = await SharedService.loginDetails();
            print("Datos de usuario obtenidos: ${userDetails != null}");
            if (userDetails != null) {
              print("Token: ${userDetails.token?.substring(0, 10)}...");
              print("Usuario: ${userDetails.data?.nombre}");
            }
            
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            setState(() {
              errorMessage = "Credenciales inválidas. Verifique su información e intente nuevamente.";
            });
          }
        }
      } catch (e) {
        print("Excepción en _loginUser: $e");
        print("Stack trace: ${StackTrace.current}");
        
        if (mounted) {
          setState(() {
            isApiCallProcess = false;
            errorMessage = "Error de conexión. Verifique su conexión a internet e intente nuevamente.";
          });
        }
      }
    }
  }
}

// Custom painter for grid background
class GridPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  GridPainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 60.0;
    final offsetX = (animationValue * spacing) % spacing;
    final offsetY = (animationValue * spacing) % spacing;

    // Draw vertical lines
    for (double x = offsetX; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = offsetY; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}