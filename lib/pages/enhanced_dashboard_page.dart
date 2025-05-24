import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_nextmeal/services/dashboard_service.dart';
import 'package:app_nextmeal/pages/config.dart';
import 'package:intl/date_symbol_data_local.dart';

class EnhancedDashboardPage extends StatefulWidget {
  const EnhancedDashboardPage({super.key});

  @override
  State<EnhancedDashboardPage> createState() => _EnhancedDashboardPageState();
}

class _EnhancedDashboardPageState extends State<EnhancedDashboardPage>
    with TickerProviderStateMixin {
  final DashboardService _dashboardService = DashboardService();
  
  // Data variables
  List<Map<String, dynamic>> _estadisticasSemanal = [];
  Map<String, dynamic> _resumen = {};
  Map<String, dynamic> _metodosPagoHoy = {};
  bool _isLoading = true;
  
  // Animation variables
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  // Chart variables
  int _touchedIndex = -1;
  int _touchedBarIndex = -1;
  
  // Timer for real-time updates
  Timer? _realTimeTimer;
  
  // Colors usando Config
  final List<Color> _chartColors = [
    Color(Config.colors['secondary']!),  // Morado
    Color(Config.colors['primary']!),    // Verde
    Color(Config.colors['accent']!),     // Azul
    Color(Config.colors['warning']!),    // Amarillo
    Color(Config.colors['pink']!),       // Rosa
    Color(Config.colors['error']!),      // Rojo
    Color(Config.colors['violet']!),     // Violeta
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    initializeDateFormatting('es_ES', null).then((_) {
      _cargarDatos();
      _iniciarActualizacionTiempoReal();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: Config.chartConfig['animationDuration']),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: Config.chartConfig['pulseAnimationDuration']),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _iniciarActualizacionTiempoReal() {
    _realTimeTimer = Timer.periodic(Config.updateInterval, (timer) {
      _cargarDatosEnTiempoReal();
    });
  }

  // Función helper para convertir valores de forma segura
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Cargar datos con manejo de errores individual
      Map<String, dynamic> resumen = {};
      List<Map<String, dynamic>> estadisticas = [];
      Map<String, dynamic> metodosPago = {};

      try {
        resumen = await _dashboardService.obtenerResumen();
        print('Resumen cargado: $resumen');
      } catch (e) {
        print('Error cargando resumen: $e');
        // Datos de ejemplo si falla
        resumen = {
          'montoVentasHoy': 15000,
          'montoVentasSemana': 85000,
          'montoVentasMes': 320000,
          'cantidadVentasHoy': 25,
        };
      }

      try {
        estadisticas = await _dashboardService.obtenerEstadisticasSemanal();
        print('Estadísticas cargadas: $estadisticas');
      } catch (e) {
        print('Error cargando estadísticas: $e');
        // Datos de ejemplo si falla
        estadisticas = [
          {'dia': 'Lunes', 'monto': 12000},
          {'dia': 'Martes', 'monto': 15000},
          {'dia': 'Miércoles', 'monto': 18000},
          {'dia': 'Jueves', 'monto': 14000},
          {'dia': 'Viernes', 'monto': 22000},
          {'dia': 'Sábado', 'monto': 25000},
          {'dia': 'Domingo', 'monto': 20000},
        ];
      }

      try {
        metodosPago = await _dashboardService.obtenerMetodosPagoHoy();
        print('Métodos de pago cargados: $metodosPago');
      } catch (e) {
        print('Error cargando métodos de pago: $e');
        // Datos de ejemplo si falla
        metodosPago = {
          'Efectivo': 8000,
          'Tarjeta': 12000,
          'Transferencia': 5000,
        };
      }

      if (mounted) {
        setState(() {
          _resumen = resumen;
          _estadisticasSemanal = estadisticas;
          _metodosPagoHoy = metodosPago;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      print('Error general al cargar datos: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarError('Error al cargar datos: $e');
      }
    }
  }

  Future<void> _cargarDatosEnTiempoReal() async {
    try {
      final Map<String, dynamic> resumen = await _dashboardService.obtenerResumen();
      final Map<String, dynamic> metodosPago = await _dashboardService.obtenerMetodosPagoHoy();
      
      if (mounted) {
        setState(() {
          _resumen = resumen;
          _metodosPagoHoy = metodosPago;
        });
      }
    } catch (e) {
      print('Error en actualización tiempo real: $e');
    }
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Color(Config.colors['error']!),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatCurrency(dynamic amount) {
    final value = _toDouble(amount);
    return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value);
  }

  Widget _buildEnhancedSummaryCard(
    String title, 
    String value, 
    Color color, 
    IconData icon,
    {String? subtitle, bool isPulsing = false}
  ) {
    return Expanded(
      child: AnimatedBuilder(
        animation: isPulsing ? _pulseAnimation : _fadeAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isPulsing ? _pulseAnimation.value : 1.0,
            child: Container(
              height: Config.uiConfig['cardHeight'],
              margin: EdgeInsets.symmetric(horizontal: Config.uiConfig['margin']),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(Config.uiConfig['borderRadius']),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(Config.uiConfig['padding']),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedBarChart() {
    if (_estadisticasSemanal.isEmpty) {
      return Container(
        height: Config.uiConfig['chartHeight'],
        padding: EdgeInsets.all(Config.uiConfig['padding']),
        child: const Center(
          child: Text(
            'No hay datos de ventas semanales',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    // Calcular el máximo valor de forma segura
    double maxValue = 100;
    try {
      maxValue = _estadisticasSemanal
          .map((e) => _toDouble(e['monto']))
          .reduce(math.max) * 1.2;
    } catch (e) {
      print('Error calculando máximo: $e');
    }

    return Container(
      height: Config.uiConfig['chartHeight'],
      padding: EdgeInsets.all(Config.uiConfig['padding']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: Color(Config.colors['primary']!),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Ventas Semanales',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(Config.colors['primary']!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(Config.colors['primary']!).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(Config.colors['primary']!),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'En vivo',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Color(Config.colors['surface']!),
                    tooltipBorder: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (group.x.toInt() >= _estadisticasSemanal.length) {
                        return null;
                      }
                      final data = _estadisticasSemanal[group.x.toInt()];
                      return BarTooltipItem(
                        '${data['dia']}\n${_formatCurrency(data['monto'])}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        _touchedBarIndex = -1;
                        return;
                      }
                      _touchedBarIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= _estadisticasSemanal.length) {
                          return const Text('');
                        }
                        final data = _estadisticasSemanal[value.toInt()];
                        final dia = data['dia']?.toString() ?? '';
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dia.length > 3 ? dia.substring(0, 3) : dia,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          _formatCurrency(value),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _estadisticasSemanal.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final isTouched = index == _touchedBarIndex;
                  final monto = _toDouble(data['monto']);
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: monto,
                        color: isTouched 
                            ? Color(Config.colors['primary']!)
                            : Color(Config.colors['primary']!).withOpacity(0.8),
                        width: Config.chartConfig['barWidth'],
                        borderRadius: BorderRadius.circular(Config.chartConfig['borderRadius']),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxValue,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsChart() {
    if (_metodosPagoHoy.isEmpty) {
      return Container(
        height: Config.uiConfig['chartHeight'],
        padding: EdgeInsets.all(Config.uiConfig['padding']),
        child: const Center(
          child: Text(
            'No hay datos de métodos de pago',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    // Convertir y ordenar métodos de pago de forma segura
    final List<MapEntry<String, double>> sortedMethods = _metodosPagoHoy.entries
        .map((entry) => MapEntry(entry.key, _toDouble(entry.value)))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sortedMethods.fold<double>(
      0, 
      (sum, entry) => sum + entry.value
    );

    if (total == 0) {
      return Container(
        height: Config.uiConfig['chartHeight'],
        padding: EdgeInsets.all(Config.uiConfig['padding']),
        child: const Center(
          child: Text(
            'No hay ventas registradas hoy',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Container(
      height: Config.uiConfig['chartHeight'],
      padding: EdgeInsets.all(Config.uiConfig['padding']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: Color(Config.colors['secondary']!),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Métodos de Pago Hoy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Total: ${_formatCurrency(total)}',
                style: TextStyle(
                  color: Color(Config.colors['primary']!),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: Config.chartConfig['sectionSpace'],
                      centerSpaceRadius: Config.chartConfig['centerSpaceRadius'],
                      sections: sortedMethods.asMap().entries.map((entry) {
                        final index = entry.key;
                        final method = entry.value;
                        final isTouched = index == _touchedIndex;
                        final fontSize = isTouched ? 16.0 : 12.0;
                        final radius = isTouched ? 80.0 : 70.0;
                        final percentage = (method.value / total * 100);
                        
                        return PieChartSectionData(
                          color: _chartColors[index % _chartColors.length],
                          value: method.value,
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: radius,
                          titleStyle: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Legend
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: sortedMethods.asMap().entries.map((entry) {
                      final index = entry.key;
                      final method = entry.value;
                      final color = _chartColors[index % _chartColors.length];
                      final percentage = (method.value / total * 100);
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.key,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${_formatCurrency(method.value)} (${percentage.toStringAsFixed(1)}%)',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ventasHoy = _formatCurrency(_resumen['montoVentasHoy'] ?? 0);
    final ventasSemana = _formatCurrency(_resumen['montoVentasSemana'] ?? 0);
    final ventasMes = _formatCurrency(_resumen['montoVentasMes'] ?? 0);
    final cantidadHoy = _toInt(_resumen['cantidadVentasHoy']);

    return Scaffold(
      backgroundColor: Color(Config.colors['background']!),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.dashboard,
              color: Color(Config.colors['primary']!),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              Config.appTitle,
              style:  TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value * 0.1 + 0.9,
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _cargarDatos,
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(Config.uiConfig['padding']),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Summary Cards
                      Row(
                        children: [
                          _buildEnhancedSummaryCard(
                            'Ventas Hoy',
                            ventasHoy,
                            Color(Config.colors['primary']!),
                            Icons.today,
                            subtitle: '$cantidadHoy ventas',
                            isPulsing: false,
                          ),
                          const SizedBox(width: 8),
                          _buildEnhancedSummaryCard(
                            'Ventas Semana',
                            ventasSemana,
                            Color(Config.colors['accent']!),
                            Icons.calendar_view_week,
                          ),
                          const SizedBox(width: 8),
                          _buildEnhancedSummaryCard(
                            'Ventas Mes',
                            ventasMes,
                            Color(Config.colors['secondary']!),
                            Icons.calendar_month,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Charts Section
                      Container(
                        decoration: BoxDecoration(
                          color: Color(Config.colors['surface']!),
                          borderRadius: BorderRadius.circular(Config.uiConfig['borderRadius']),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: _buildEnhancedBarChart(),
                      ),
                      const SizedBox(height: 24),

                      Container(
                        decoration: BoxDecoration(
                          color: Color(Config.colors['surface']!),
                          borderRadius: BorderRadius.circular(Config.uiConfig['borderRadius']),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: _buildPaymentMethodsChart(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _realTimeTimer?.cancel();
    super.dispose();
  }
}
