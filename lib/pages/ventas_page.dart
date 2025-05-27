import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_nextmeal/models/venta_model.dart';
import 'package:app_nextmeal/services/venta_service.dart';
import 'package:app_nextmeal/pages/config.dart';
import 'package:app_nextmeal/pages/venta_detalle_page.dart';

class VentasPage extends StatefulWidget {
  const VentasPage({super.key});

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  // Variables para manejar el estado
  List<Venta> _ventasOriginales = [];
  List<Venta> _ventasFiltradas = [];
  bool isLoading = true;
  String? error;
  
  final TextEditingController _searchController = TextEditingController();
  String _filtroMetodo = 'Todos los métodos';

  final List<String> _metodosPago = [
    'Todos los métodos',
    'efectivo',
    'transferencia',
    'Todas las ventas',
  ];

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarVentas() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      if (Config.enableLogging) {
        print('Iniciando carga de ventas...');
      }

      final ventas = await VentaService.obtenerVentas();
      
      if (Config.enableLogging) {
        print('Ventas obtenidas: ${ventas.length}');
      }

      setState(() {
        _ventasOriginales = ventas;
        _ventasFiltradas = ventas;
        isLoading = false;
      });

      _filtrarVentas();

    } catch (e) {
      if (Config.enableLogging) {
        print('Error al cargar ventas: $e');
      }
      
      setState(() {
        error = e.toString();
        isLoading = false;
      });

      if (e.toString().contains('No hay sesión activa') || 
          e.toString().contains('sesión') ||
          e.toString().contains('token') ||
          e.toString().contains('Sesión expirada')) {
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Sesión expirada. Redirigiendo al login...'),
              backgroundColor: Color(Config.colors['error']!),
            ),
          );
          
          await Future.delayed(const Duration(seconds: 2));
          
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Color(Config.colors['error']!),
            ),
          );
        }
      }
    }
  }

  void _filtrarVentas() {
    setState(() {
      _ventasFiltradas = _ventasOriginales.where((venta) {
        final cumpleBusqueda = _searchController.text.isEmpty ||
            venta.nombreCliente.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            venta.id.toString().contains(_searchController.text) ||
            (venta.pedido?.cliente?.correoElectronico.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
        
        final cumpleMetodo = _filtroMetodo == 'Todos los métodos' ||
            venta.metodoPago.toLowerCase() == _filtroMetodo.toLowerCase() ||
            (_filtroMetodo == 'Todas las ventas' && 
             (venta.metodoPago.toLowerCase() == 'efectivo' || venta.metodoPago.toLowerCase() == 'transferencia'));
        
        return cumpleBusqueda && cumpleMetodo;
      }).toList();
    });
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy, HH:mm').format(date);
  }

  Color _getMetodoPagoColor(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'efectivo':
        return Color(Config.colors['success']!);
      case 'transferencia':
        return Color(Config.colors['accent']!);
      case 'Todas las ventas':
        return Color(Config.colors['primary']!);
      default:
        return Colors.grey;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
        return Color(Config.colors['success']!);
      case 'pendiente':
        return Color(Config.colors['warning']!);
      case 'cancelado':
        return Color(Config.colors['error']!);
      default:
        return Colors.grey;
    }
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(Config.uiConfig['padding']),
      decoration: BoxDecoration(
        color: Color(Config.colors['surface']!),
        borderRadius: BorderRadius.circular(Config.uiConfig['borderRadius'] * 0.75),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _filtrarVentas(),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar por cliente, email o ID...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Config.uiConfig['padding'], 
            vertical: Config.uiConfig['padding'] * 0.75
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Config.uiConfig['padding']),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color(Config.colors['surface']!),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filtroMetodo,
                  onChanged: (String? newValue) {
                    setState(() {
                      _filtroMetodo = newValue!;
                      _filtrarVentas();
                    });
                  },
                  dropdownColor: Color(Config.colors['surface']!),
                  style: const TextStyle(color: Colors.white),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  items: _metodosPago.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'Todos los métodos' ? value : value.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVentaCard(Venta venta) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Config.uiConfig['padding'],
        vertical: Config.uiConfig['padding'] * 0.5,
      ),
      decoration: BoxDecoration(
        color: Color(Config.colors['surface']!),
        borderRadius: BorderRadius.circular(Config.uiConfig['borderRadius'] * 0.75),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Config.uiConfig['borderRadius'] * 0.75),
          onTap: () {
            if (Config.enableLogging) {
              print('Navegando a detalles de venta: ${venta.id}');
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VentaDetallePage(venta: venta),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(Config.uiConfig['padding']),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con ID y fecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(Config.colors['primary']!).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.receipt_long,
                            color: Color(Config.colors['primary']!),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Venta #${venta.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(venta.fecha),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Cliente
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        venta.nombreCliente,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Total y método de pago
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatCurrency(venta.total),
                      style: TextStyle(
                        color: Color(Config.colors['warning']!),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getMetodoPagoColor(venta.metodoPago),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        venta.metodoPago.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Estado del pedido si está disponible
                if (venta.pedido != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white.withOpacity(0.5),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Estado: ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getEstadoColor(venta.pedido!.estado),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          venta.pedido!.estado.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Color(Config.colors['surface']!),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No se encontraron ventas',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta ajustar los filtros de búsqueda',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Color(Config.colors['surface']!),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Color(Config.colors['error']!),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Error al cargar ventas',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error ?? 'Error desconocido',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _cargarVentas,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(Config.colors['primary']!),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(Config.colors['background']!),
      appBar: AppBar(
        backgroundColor: Color(Config.colors['surface']!),
        elevation: 0,
        title: const Text(
          'Ventas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: isLoading ? null : _cargarVentas,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          _buildSearchBar(),
          
          // Filtros
          _buildFilterDropdown(),
          
          const SizedBox(height: 8),
          
          // Contenido principal
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : error != null
                    ? _buildErrorState()
                    : _ventasFiltradas.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _cargarVentas,
                            color: Color(Config.colors['primary']!),
                            child: ListView.builder(
                              itemCount: _ventasFiltradas.length,
                              itemBuilder: (context, index) {
                                return _buildVentaCard(_ventasFiltradas[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}