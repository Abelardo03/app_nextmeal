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
        title: const Text(
          'Detalles de la Venta',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Config.uiConfig['padding']),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                  _buildInfoRow('Cliente:', venta.nombreCliente),
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
            ),
          ],
        ),
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
