import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_nextmeal/services/dashboard_service.dart';
import 'package:intl/date_symbol_data_local.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService _dashboardService = DashboardService();
  List<Map<String, dynamic>> _estadisticasDiarias = [];
  Map<String, dynamic> _resumen = {};
  bool _isLoading = true;
  int _touchedIndex = -1;
  bool _isPlaying = false;
  final Duration _animDuration = const Duration(milliseconds: 250);

  // Colores para la gráfica
  final List<Color> _availableColors = <Color>[
    Color(0xFF6D28D9), // Morado
    Color(0xFFF59E0B), // Amarillo
    Color(0xFF3B82F6), // Azul
    Color(0xFFF97316), // Naranja
    Color(0xFFEC4899), // Rosa
    Color(0xFFEF4444), // Rojo
  ];

  final Color _barBackgroundColor = Colors.white.withOpacity(0.3);
  final Color _barColor = Colors.white;
  final Color _touchedBarColor = Color(0xFF10B981); // Verde

  @override
  void initState() {
    super.initState();
    // Inicializar formato de fecha y luego cargar datos
    initializeDateFormatting('es_ES', null).then((_) {
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final resumen = await _dashboardService.obtenerResumen();
      final estadisticas = await _dashboardService.obtenerEstadisticasDiarias();

      print('Resumen cargado: $resumen');
      print('Estadísticas diarias cargadas: $estadisticas');

      // Calcular montoVentasHoy manualmente si no está presente en el resumen
      if (!resumen.containsKey('montoVentasHoy') ||
          resumen['montoVentasHoy'] == 0) {
        final fechaHoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
        print('Buscando datos para la fecha de hoy: $fechaHoy');

        final datosHoy = estadisticas.firstWhere(
          (e) => e['fecha'] == fechaHoy,
          orElse: () => {'monto':0, 'ventas': 0},
        );

        print('Datos encontrados para hoy: $datosHoy');

        resumen['montoVentasHoy'] = datosHoy['monto'] ?? 0;
        resumen['ventasHoy'] = datosHoy['ventas'] ?? datosHoy['cantidad'] ?? 0;
      }

      if (mounted) {
        setState(() {
          _resumen = resumen;
          _estadisticasDiarias = estadisticas;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar datos: $e'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(num amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(amount);
  }

  // Método para crear datos de grupo de barras
  BarChartGroupData _makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    barColor ??= _barColor;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? _touchedBarColor : barColor,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: _touchedBarColor.withOpacity(0.8))
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: _barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  // Crear grupos de datos para mostrar
  List<BarChartGroupData> _showingGroups() {
    if (_estadisticasDiarias.isEmpty) {
      // Si no hay datos, devolver barras vacías
      return List.generate(7, (i) => _makeGroupData(i, 0));
    }

    // Limitar a los últimos 7 días si hay más
    final datos = _estadisticasDiarias.length > 7
        ? _estadisticasDiarias.sublist(0, 7)
        : _estadisticasDiarias;

    return List.generate(datos.length, (i) {
      final monto = (datos[i]['monto'] ?? 0) as num;
      return _makeGroupData(
        i,
        monto.toDouble(),
        isTouched: i == _touchedIndex,
      );
    });
  }

  // Método para obtener datos aleatorios (animación)
  BarChartData _randomData() {
    return BarChartData(
      barTouchData: BarTouchData(
        enabled: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: _getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: List.generate(7, (i) {
        return _makeGroupData(
          i,
          math.Random().nextInt(15).toDouble() + 6,
          barColor:
              _availableColors[math.Random().nextInt(_availableColors.length)],
        );
      }),
      gridData: const FlGridData(show: false),
    );
  }

  // Datos principales para el gráfico de barras
  BarChartData _mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            if (groupIndex >= _estadisticasDiarias.length) {
              return null;
            }

            final data = _estadisticasDiarias[groupIndex];
            final fecha = DateTime.parse(data['fecha']);
            String diaSemana = DateFormat.EEEE('es_ES').format(fecha);

            return BarTooltipItem(
              '$diaSemana\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: _formatCurrency(
                      (rod.toY - (groupIndex == _touchedIndex ? 1 : 0))
                          .toInt()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              _touchedIndex = -1;
              return;
            }
            _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
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
            getTitlesWidget: _getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: _showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }

  // Widget para mostrar los títulos inferiores
  Widget _getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    if (_estadisticasDiarias.isEmpty ||
        value.toInt() >= _estadisticasDiarias.length) {
      // Si no hay datos o el índice está fuera de rango, usar abreviaturas genéricas
      final dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
      if (value.toInt() < dias.length) {
        return SideTitleWidget(
          axisSide: meta.axisSide,
          space: 16,
          child: Text(dias[value.toInt()], style: style),
        );
      }
      return const SizedBox();
    }

    // Si hay datos, usar la fecha real
    try {
      final fecha =
          DateTime.parse(_estadisticasDiarias[value.toInt()]['fecha']);
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 16,
        child: Text(
          DateFormat.E('es_ES').format(fecha)[0].toUpperCase(),
          style: style,
        ),
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  // Método para refrescar el estado durante la animación
  Future<dynamic> _refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
      _animDuration + const Duration(milliseconds: 50),
    );
    if (_isPlaying) {
      await _refreshState();
    }
  }

  // Widget para el gráfico de barras mejorado
  Widget _buildEnhancedBarChart() {
    if (_estadisticasDiarias.isEmpty) {
      return const Center(
        child: Text(
          'No hay ventas registradas en la semana actual',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Semanal',
                  style: TextStyle(
                    color: Color(0xFF10B981), // Verde
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gráfico de ventas diarias',
                  style: TextStyle(
                    color: const Color(0xFF10B981).withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BarChart(
                      _isPlaying ? _randomData() : _mainBarData(),
                      swapAnimationDuration: _animDuration,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: const Color(0xFF10B981),
                ),
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                    if (_isPlaying) {
                      _refreshState();
                    }
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ventasHoy = _formatCurrency(_resumen['montoVentasHoy'] ?? 0);
    final ventasSemana = _formatCurrency(_resumen['montoTotal'] ?? 0);
    final ventasMes = _formatCurrency(_resumen['montoTotal'] ?? 0);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildSummaryCard(
                          'Ventas Hoy', ventasHoy, Colors.blueAccent),
                      const SizedBox(width: 8),
                      _buildSummaryCard(
                          'Ventas Semana', ventasSemana, Colors.greenAccent),
                      const SizedBox(width: 8),
                      _buildSummaryCard(
                          'Ventas Mes', ventasMes, Colors.purpleAccent),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ventas por Día de la Semana',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    height:
                        400, // Aumentamos la altura para dar más espacio al gráfico
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildEnhancedBarChart(),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
