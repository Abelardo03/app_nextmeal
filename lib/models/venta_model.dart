class Venta {
  final int id;
  final String nombreCliente;
  final double total;
  final DateTime fecha;
  final String metodoPago;

  Venta({
    required this.id,
    required this.nombreCliente,
    required this.total,
    required this.fecha,
    required this.metodoPago,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    // Extraer el ID del cliente si está disponible
    final clienteData = json['cliente'];
    final String nombreCliente = clienteData != null && clienteData['nombrecompleto'] != null
        ? clienteData['nombrecompleto']
        : json['nombreCliente'] ?? 'Cliente';
    
    // Extraer el total a pagar
    final double total = json['total_pagar'] != null
        ? double.tryParse(json['total_pagar'].toString()) ?? 0.0
        : 0.0;
    
    // Extraer la fecha
    DateTime fecha;
    try {
      fecha = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now();
    } catch (e) {
      fecha = DateTime.now();
    }
    
    return Venta(
      id: json['id'] ?? 0,
      nombreCliente: nombreCliente,
      total: total,
      fecha: fecha,
      metodoPago: json['metodo_pago'] ?? 'efectivo',
    );
  }
}
