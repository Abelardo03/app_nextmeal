// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:app_nextmeal/models/venta_model.dart';
// import 'package:app_nextmeal/services/api_service.dart';

// class VentasPage extends StatefulWidget {
//   const VentasPage({Key? key}) : super(key: key);

//   @override
//   _VentasPageState createState() => _VentasPageState();
// }

// class _VentasPageState extends State<VentasPage> {
//   late Future<List<Venta>> _ventasFuture;
//   final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

//   @override
//   void initState() {
//     super.initState();
//     _cargarVentas();
//   }

//   void _cargarVentas() {
//     setState(() {
//       _ventasFuture = APIService.getVentas();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Ventas'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _cargarVentas,
//           ),
//         ],
//       ),
//       body: FutureBuilder<List<Venta>>(
//         future: _ventasFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, size: 60, color: Colors.red),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Error al cargar ventas:\n${snapshot.error}',
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: _cargarVentas,
//                     child: const Text('Reintentar'),
//                   ),
//                 ],
//               ),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text(
//                 'No hay ventas registradas',
//                 style: TextStyle(fontSize: 18),
//               ),
//             );
//           }

//           final ventas = snapshot.data!;
//           return ListView.builder(
//             itemCount: ventas.length,
//             itemBuilder: (context, index) {
//               final venta = ventas[index];
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 elevation: 2,
//                 child: ExpansionTile(
//                   title: Text(
//                     'Venta #${venta.id}',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Cliente: ${venta.nombreCliente}'),
//                       Text('Fecha: ${venta.fecha}'),
//                       Text(
//                         'Total: ${currencyFormat.format(venta.total)}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                         ),
//                       ),
//                     ],
//                   ),
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Divider(),
//                           Text('Método de pago: ${venta.metodoPago}'),
//                           Text('Estado: ${venta.estado}'),
//                           const SizedBox(height: 8),
//                           const Text(
//                             'Detalles de la venta:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 8),
//                           ...venta.detalles.map((detalle) => Padding(
//                             padding: const EdgeInsets.only(bottom: 4.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Text(detalle.nombreProducto),
//                                 ),
//                                 Expanded(
//                                   flex: 1,
//                                   child: Text('${detalle.cantidad}x'),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Text(
//                                     currencyFormat.format(detalle.precioUnitario),
//                                     textAlign: TextAlign.right,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Text(
//                                     currencyFormat.format(detalle.subtotal),
//                                     textAlign: TextAlign.right,
//                                     style: const TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )).toList(),
//                           const Divider(),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               const Text(
//                                 'Total: ',
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                 currencyFormat.format(venta.total),
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
