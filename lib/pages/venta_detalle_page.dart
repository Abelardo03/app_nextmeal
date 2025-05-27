import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_nextmeal/models/venta_model.dart';
import 'package:app_nextmeal/pages/config.dart';

class VentaDetallePage extends StatelessWidget {
  final Venta venta;

  const VentaDetallePage({Key? key, required this.venta}) : super(key: key);

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy, HH:mm p.m.').format(date);
  }

  Color _getMetodoPagoColor(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'efectivo':
        return Color(Config.colors['success']!);
      case 'transferencia':
        return Color(Config.colors['accent']!);
      case 'tarjeta':
        return Color(Config.colors['secondary']!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(Config.colors['background']!),
      appBar: AppBar(
        backgroundColor: Color(Config.colors['surface']!),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Config.enableLogging) {
              print('Regresando de detalles de venta');
            }
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Venta #${venta.id}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Config.uiConfig['padding']),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la venta
            _buildVentaInfoCard(),
            const SizedBox(height: 16),
            
            // Información del cliente
            if (venta.pedido?.cliente != null) ...[
              _buildClienteInfoCard(),
              const SizedBox(height: 16),
            ],
            
            // Información del pedido
            if (venta.pedido != null) ...[
              _buildPedidoInfoCard(),
              const SizedBox(height: 16),
            ],
            
            // Productos del pedido
            if (venta.pedido?.productos != null && venta.pedido!.productos!.isNotEmpty) ...[
              _buildProductosCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVentaInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Config.uiConfig['padding'] * 1.25),
      decoration: BoxDecoration(
        color: Color(Config.colors['surface']!),
        borderRadius: BorderRadius.circular(Config.uiConfig['borderRadius'] * 0.75),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(Config.colors['warning']!).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: Color(Config.colors['warning']!),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Información de la Venta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('ID Venta:', '#${venta.id}'),
          const SizedBox(height: 12),
          _buildInfoRow('Fecha de Venta:', _formatDate(venta.fecha)),
          const SizedBox(height: 12),
          _buildInfoRow('Total Pagado:', _formatCurrency(venta.total), isAmount: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Método de Pago:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClienteInfoCard() {
    final cliente = venta.pedido!.cliente!;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Config.uiConfig['padding'] * 1.25),
      decoration: BoxDecoration(
        color: Color(Config.colors['surface']!),
        borderRadius: BorderRadius.circular(Config.uiConfig['borderRadius'] * 0.75),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.person,
                  color: Color(Config.colors['primary']!),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Información del Cliente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Nombre:', cliente.nombreCompleto),
          const SizedBox(height: 12),
          _buildInfoRow('Teléfono:', cliente.telefono),
          const SizedBox(height: 12),
          _buildInfoRow('Email:', cliente.correoElectronico),
        ],
      ),
    );
  }

  Widget _buildPedidoInfoCard() {
    final pedido = venta.pedido!;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Config.uiConfig['padding'] * 1.25),
      decoration: BoxDecoration(
        color: Color(Config.colors['surface']!),
        borderRadius: BorderRadius.circular(Config.uiConfig['borderRadius'] * 0.75),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(Config.colors['accent']!).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_bag,
                  color: Color(Config.colors['accent']!),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Información del Pedido',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('ID Pedido:', '#${pedido.id}'),
          const SizedBox(height: 12),
          _buildInfoRow('Fecha Pedido:', _formatDate(DateTime.tryParse(pedido.fechaPedido) ?? DateTime.now())),
          const SizedBox(height: 12),
          _buildInfoRow('Dirección:', pedido.direccionEnvio),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Estado:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getEstadoColor(pedido.estado),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  pedido.estado,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductosCard() {
    final productos = venta.pedido!.productos!;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Config.uiConfig['padding'] * 1.25),
      decoration: BoxDecoration(
        color: Color(Config.colors['surface']!),
        borderRadius: BorderRadius.circular(Config.uiConfig['borderRadius'] * 0.75),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(Config.colors['success']!).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory,
                  color: Color(Config.colors['success']!),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Productos (${productos.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...productos.map((producto) => _buildProductoItem(producto)).toList(),
        ],
      ),
    );
  }

  Widget _buildProductoItem(Producto producto) {
    final pedidoProducto = producto.pedidoProducto;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  producto.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (pedidoProducto != null)
                Text(
                  'x${pedidoProducto.cantidad}',
                  style: TextStyle(
                    color: Color(Config.colors['warning']!),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (producto.descripcion.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              producto.descripcion,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
          if (pedidoProducto != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Precio unitario: ${_formatCurrency(pedidoProducto.precioUnitario.toDouble())}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Subtotal: ${_formatCurrency(pedidoProducto.subtotal.toDouble())}',
                  style: TextStyle(
                    color: Color(Config.colors['warning']!),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false, bool isAmount = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isHighlight 
                  ? Color(Config.colors['warning']!)
                  : isAmount 
                      ? Color(Config.colors['warning']!)
                      : Colors.white,
              fontSize: isAmount ? 18 : 14,
              fontWeight: isHighlight || isAmount ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}