class Producto {
  final int? id; 
  final String nombre;
  final String descripcion;
  final String codigoBarras;
  final String categoria;
  final double precio;
  final int stock;
  final String proveedor;
  final String? fechaIngreso; 
  final bool activo;

  Producto({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.codigoBarras,
    required this.categoria,
    required this.precio,
    required this.stock,
    required this.proveedor,
    this.fechaIngreso,
    this.activo = true, 
  });

  // Crea un objeto Producto desde un JSON (usado para READ)
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: int.tryParse(json['id'].toString()),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      codigoBarras: json['codigo_barras'] as String,
      categoria: json['categoria'] as String,
      precio: double.tryParse(json['precio'].toString()) ?? 0.0, 
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      proveedor: json['proveedor'] as String,
      fechaIngreso: json['fecha_ingreso'] as String?,
      activo: json['activo'].toString() == '1' || json['activo'] == true, 
    );
  }

  // Convierte el objeto Producto a un Map (JSON) (usado para CREATE/UPDATE)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'codigo_barras': codigoBarras,
      'categoria': categoria,
      'precio': precio, 
      'stock': stock,
      'proveedor': proveedor,
      'activo': activo ? 1 : 0,
    };
  }
}