import 'package:flutter/material.dart';
import 'enhanced_dashboard_page.dart';
import 'ventas_page.dart' as ventas;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    
    // Inicializar animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Inicializar páginas - CORREGIDO: usar la página real de ventas
    _pages = [
      const EnhancedDashboardPage(), // Dashboard mejorado como página principal
      const ventas.VentasPage(), // Página real de gestión de ventas
      const ConfiguracionPage(),
    ];
    
    _animationController.forward();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _animationController.reset();
      setState(() {
        _selectedIndex = index;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Ventas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Config',
            ),
          ],
        ),
      ),
    );
  }
}

// Página temporal de Configuración
class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.settings,
              color: Color(0xFF10B981),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Configuración',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfigCard(
              'Dashboard Original',
              'Ver el dashboard básico',
              Icons.dashboard_outlined,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnhancedDashboardPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildConfigCard(
              'Debug API',
              'Probar endpoints del servidor',
              Icons.bug_report_outlined,
              () {
                Navigator.pushNamed(context, '/debug');
              },
            ),
            const SizedBox(height: 16),
            _buildConfigCard(
              'Acerca de',
              'Información de la aplicación',
              Icons.info_outlined,
              () {
                _showAboutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      color: const Color(0xFF161B22),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF10B981),
          size: 28,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          'NextMeal Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versión: 1.0.0',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              'Dashboard avanzado para gestión de ventas con gráficos interactivos y actualización en tiempo real.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }
}
