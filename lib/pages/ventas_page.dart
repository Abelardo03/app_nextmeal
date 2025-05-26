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
  late Future<List<Venta>> _ventasFuture;
  final TextEditingController _searchController = TextEditingController();
  String _filtroMetodo = 'Todos los métodos';
  List<Venta> _ventasOriginales = [];
  List<Venta> _ventasFiltradas = [];

  final List<String> _metodosPago = [
    'Todos los métodos',
    'Efectivo',
    'Transferencia',
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

  void _cargarVentas() {
    setState(() {
      _ventasFuture = VentaService.obtenerVentas();
    });
  }

  void _filtrarVentas() {
    setState(() {
      _ventasFiltradas = _ventasOriginales.where((venta) {
        final cumpleBusqueda = _searchController.text.isEmpty ||
            venta.nombreCliente.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            venta.id.toString().contains(_searchController.text);
        
        final cumpleMetodo = _filtroMetodo == 'Todos los métodos' ||
            venta.metodoPago.toLowerCase() == _filtroMetodo.toLowerCase();
        
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
          hintText: 'Buscar...',
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
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Color(Config.colors['accent']!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _cargarVentas,
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Color(Config.colors['primary']!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                if (Config.enableLogging) {
                  print('Botón agregar venta presionado');
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
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
        vertical: Config.uiConfig['margin'] * 1.5
      ),
      decoration: BoxDecoration(
        color: Color(Config.colors['surface']!),
        borderRadius: BorderRadius.circular(Config.uiConfig['borderRadius'] * 0.75),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(Config.uiConfig['padding']),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatDate(venta.fecha),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              venta.nombreCliente,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getMetodoPagoColor(venta.metodoPago),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    venta.metodoPago,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _formatCurrency(venta.total),
                      style: TextStyle(
                        color: Color(Config.colors['warning']!),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (Config.enableLogging) {
                          print('Ver detalles de venta #${venta.id}');
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VentaDetallePage(venta: venta),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.visibility,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
          'Gestión de Ventas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterDropdown(),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Venta>>(
              future: _ventasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(Config.colors['primary']!)),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Color(Config.colors['error']!).withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar ventas',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _cargarVentas,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(Config.colors['primary']!),
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 60,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay ventas registradas',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                _ventasOriginales = snapshot.data!;
                if (_ventasFiltradas.isEmpty && _searchController.text.isEmpty && _filtroMetodo == 'Todos los métodos') {
                  _ventasFiltradas = _ventasOriginales;
                }

                final ventasAMostrar = _ventasFiltradas.isEmpty ? _ventasOriginales : _ventasFiltradas;

                return ListView.builder(
                  itemCount: ventasAMostrar.length,
                  itemBuilder: (context, index) {
                    return _buildVentaCard(ventasAMostrar[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
