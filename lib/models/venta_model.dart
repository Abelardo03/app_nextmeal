class Venta {
  final int id;
  final String nombreCliente;
  final DateTime fecha;
  final double total;
  final String metodoPago;
  final int? idPedido;

  Venta({
    required this.id,
    required this.nombreCliente,
    required this.fecha,
    required this.total,
    required this.metodoPago,
    this.idPedido,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    // Adaptado para la estructura de tu backend
    return Venta(
      id: json['id'] ?? 0,
      nombreCliente: _extraerNombreCliente(json),
      fecha: _parsearFecha(json['createdAt'] ?? json['fecha']),
      total: _parsearTotal(json['total_pagar'] ?? json['total']),
      metodoPago: json['metodo_pago'] ?? json['metodoPago'] ?? 'efectivo',
      idPedido: json['id_pedido'],
    );
  }

  static String _extraerNombreCliente(Map<String, dynamic> json) {
    // Si viene del backend con relación de pedido y cliente
    if (json['Pedido'] != null && json['Pedido']['Cliente'] != null) {
      return json['Pedido']['Cliente']['nombrecompleto'] ?? 'Cliente desconocido';
    }
    
    // Si viene directamente
    return json['nombre_cliente'] ?? json['nombreCliente'] ?? 'Cliente desconocido';
  }

  static DateTime _parsearFecha(dynamic fecha) {
    if (fecha == null) return DateTime.now();
    
    if (fecha is String) {
      return DateTime.tryParse(fecha) ?? DateTime.now();
    }
    
    return DateTime.now();
  }

  static double _parsearTotal(dynamic total) {
    if (total == null) return 0.0;
    
    if (total is String) {
      return double.tryParse(total) ?? 0.0;
    }
    
    if (total is int) {
      return total.toDouble();
    }
    
    if (total is double) {
      return total;
    }
    
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_cliente': nombreCliente,
      'fecha': fecha.toIso8601String(),
      'total_pagar': total,
      'metodo_pago': metodoPago,
      if (idPedido != null) 'id_pedido': idPedido,
    };
  }

  @override
  String toString() {
    return 'Venta{id: $id, cliente: $nombreCliente, total: $total, metodo: $metodoPago}';
  }
}
