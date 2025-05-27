class Venta {
  final int id;
  final int idPedido;
  final String fechaVenta;
  final String totalPagar;
  final String metodoPago;
  final String createdAt;
  final String updatedAt;
  final Pedido? pedido;

  Venta({
    required this.id,
    required this.idPedido,
    required this.fechaVenta,
    required this.totalPagar,
    required this.metodoPago,
    required this.createdAt,
    required this.updatedAt,
    this.pedido,
  });

  // Getters de conveniencia para compatibilidad con el código existente
  String get nombreCliente => pedido?.cliente?.nombreCompleto ?? 'Cliente desconocido';
  DateTime get fecha => DateTime.tryParse(fechaVenta) ?? DateTime.tryParse(createdAt) ?? DateTime.now();
  double get total => double.tryParse(totalPagar) ?? 0.0;

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'] ?? 0,
      idPedido: json['id_pedido'] ?? 0,
      fechaVenta: json['fecha_venta'] ?? '',
      totalPagar: json['total_pagar']?.toString() ?? '0',
      metodoPago: json['metodo_pago'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      pedido: json['Pedido'] != null ? Pedido.fromJson(json['Pedido']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_pedido': idPedido,
      'fecha_venta': fechaVenta,
      'total_pagar': totalPagar,
      'metodo_pago': metodoPago,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'Pedido': pedido?.toJson(),
    };
  }

  @override
  String toString() {
    return 'Venta{id: $id, cliente: $nombreCliente, total: $total, metodo: $metodoPago}';
  }
}

class Pedido {
  final int id;
  final int idCliente;
  final int total;
  final String direccionEnvio;
  final String fechaPedido;
  final String estado;
  final String createdAt;
  final String updatedAt;
  final Cliente? cliente;
  final List<Producto>? productos;

  Pedido({
    required this.id,
    required this.idCliente,
    required this.total,
    required this.direccionEnvio,
    required this.fechaPedido,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.cliente,
    this.productos,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'] ?? 0,
      idCliente: json['id_cliente'] ?? 0,
      total: json['total'] ?? 0,
      direccionEnvio: json['direccion_envio'] ?? '',
      fechaPedido: json['fecha_pedido'] ?? '',
      estado: json['estado'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      cliente: json['Cliente'] != null ? Cliente.fromJson(json['Cliente']) : null,
      productos: json['Productos'] != null 
          ? (json['Productos'] as List).map((x) => Producto.fromJson(x)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_cliente': idCliente,
      'total': total,
      'direccion_envio': direccionEnvio,
      'fecha_pedido': fechaPedido,
      'estado': estado,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'Cliente': cliente?.toJson(),
      'Productos': productos?.map((x) => x.toJson()).toList(),
    };
  }
}

class Cliente {
  final int id;
  final String nombreCompleto;
  final String telefono;
  final String correoElectronico;

  Cliente({
    required this.id,
    required this.nombreCompleto,
    required this.telefono,
    required this.correoElectronico,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] ?? 0,
      nombreCompleto: json['nombrecompleto'] ?? '',
      telefono: json['telefono'] ?? '',
      correoElectronico: json['correoElectronico'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombrecompleto': nombreCompleto,
      'telefono': telefono,
      'correoElectronico': correoElectronico,
    };
  }
}

class Producto {
  final int id;
  final String nombre;
  final String precio;
  final String descripcion;
  final PedidoProducto? pedidoProducto;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.descripcion,
    this.pedidoProducto,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      precio: json['precio']?.toString() ?? '0',
      descripcion: json['descripcion'] ?? '',
      pedidoProducto: json['PedidoProducto'] != null 
          ? PedidoProducto.fromJson(json['PedidoProducto']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'descripcion': descripcion,
      'PedidoProducto': pedidoProducto?.toJson(),
    };
  }
}

class PedidoProducto {
  final int cantidad;
  final int precioUnitario;
  final int subtotal;

  PedidoProducto({
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory PedidoProducto.fromJson(Map<String, dynamic> json) {
    return PedidoProducto(
      cantidad: json['cantidad'] ?? 0,
      precioUnitario: json['precio_unitario'] ?? 0,
      subtotal: json['subtotal'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}