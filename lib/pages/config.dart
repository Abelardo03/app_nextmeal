class Config {
  // Configuración básica de la app
  static const String appname = "app_nextmeal";
  static const String apiurl = "localhost:3000";
  
  // APIs existentes
  static const String loginapi = "/api/autenticacion/register";
  static const String estadisticasapi = "/api/dashboard";
  static const String ventasapi = "/api/ventas";
  
  // Nuevas APIs para el dashboard mejorado
  static const String dashboardResumenApi = "/api/dashboard/resumen";
  static const String dashboardEstadisticasSemanales = "/api/dashboard/estadisticas/semanal";
  static const String dashboardMetodosPagoHoy = "/api/dashboard/metodos-pago/hoy";
  static const String dashboardVentasTiempoReal = "/api/dashboard/ventas/tiempo-real";
  
  // Configuración de la aplicación
  static const String appVersion = "1.0.0";
  static const String appTitle = "NextMeal Dashboard";
  
  // Configuración de actualización en tiempo real
  static const Duration updateInterval = Duration(seconds: 30);
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Configuración de colores (en formato hex)
  static const Map<String, int> colors = {
    'primary': 0xFF10B981,      // Verde principal
    'secondary': 0xFF6D28D9,    // Morado
    'accent': 0xFF3B82F6,       // Azul
    'warning': 0xFFF59E0B,      // Amarillo
    'error': 0xFFEF4444,        // Rojo
    'success': 0xFF10B981,      // Verde éxito
    'background': 0xFF0D1117,   // Fondo oscuro
    'surface': 0xFF161B22,      // Superficie
    'pink': 0xFFEC4899,         // Rosa
    'violet': 0xFF8B5CF6,       // Violeta
  };
  
  // Configuración de endpoints completos
  static String get baseUrl => 'http://$apiurl';
  
  // Métodos helper para construir URLs completas
  static String getLoginUrl() => '$baseUrl$loginapi';
  static String getEstadisticasUrl() => '$baseUrl$estadisticasapi';
  static String getVentasUrl() => '$baseUrl$ventasapi';
  static String getDashboardResumenUrl() => '$baseUrl$dashboardResumenApi';
  static String getDashboardEstadisticasSemanalesUrl() => '$baseUrl$dashboardEstadisticasSemanales';
  static String getDashboardMetodosPagoHoyUrl() => '$baseUrl$dashboardMetodosPagoHoy';
  static String getDashboardVentasTiempoRealUrl() => '$baseUrl$dashboardVentasTiempoReal';
  
  // Configuración de gráficos
  static const Map<String, dynamic> chartConfig = {
    'barWidth': 20.0,
    'borderRadius': 6.0,
    'animationDuration': 1500,
    'pulseAnimationDuration': 2000,
    'centerSpaceRadius': 50.0,
    'sectionSpace': 4.0,
  };
  
  // Configuración de UI
  static const Map<String, dynamic> uiConfig = {
    'cardHeight': 100.0,
    'chartHeight': 300.0,
    'borderRadius': 16.0,
    'padding': 16.0,
    'margin': 4.0,
  };
  
  // Headers por defecto para las peticiones HTTP
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Configuración de debug
  static const bool isDebugMode = true;
  static const bool enableLogging = true;
}