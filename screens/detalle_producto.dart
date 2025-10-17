import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/inventario_service.dart';
import 'editar_productos.dart';

class DetalleProductoScreen extends StatelessWidget {
  final Producto producto;
  final InventarioService _inventarioService = InventarioService();

  DetalleProductoScreen({super.key, required this.producto});

  // Función completa para confirmar y eliminar
  void _confirmarYEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar ${producto.nombre}? Esta acción es irreversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Cierra el diálogo de confirmación
              try {
                // LLAMADA AL SERVICIO DE ELIMINACIÓN
                await _inventarioService.eliminarProducto(producto.id!);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🗑️ Producto eliminado con éxito!')),
                );
                
                // Cierra la pantalla de detalle y envía 'true' para refrescar la lista
                Navigator.pop(context, true); 
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Error al eliminar: $e')),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        actions: [
          // Lógica de navegación para el botón EDITAR
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navega a la pantalla de edición y espera un resultado (refresh)
              final refresh = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarProductoScreen(producto: producto),
                ),
              );
              // Si la edición fue exitosa, cerramos esta pantalla y notificamos a la lista
              if (refresh == true) {
                Navigator.pop(context, true); 
              }
            },
          ),
          // Botón ELIMINAR
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => _confirmarYEliminar(context),
            color: Colors.red,
          ),
        ],
      ),
      // ... (El resto del build se mantiene igual con las mejoras visuales)
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MEJORA VISUAL: Header del Producto con Nombre y Precio
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.amberAccent,
                    ),
                  ),
                ],
              ),
            ),
            
            // Sección de Detalles
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildDetailRow(Icons.description, 'Descripción', producto.descripcion),
                  _buildDetailRow(Icons.qr_code_scanner, 'Código de Barras', producto.codigoBarras),
                  _buildDetailRow(Icons.category, 'Categoría', producto.categoria),
                  
                  // Separación para detalles de Inventario
                  const Divider(height: 30, thickness: 1),
                  
                  _buildDetailRow(Icons.inventory, 'Stock Disponible', producto.stock.toString(), 
                      color: producto.stock < 5 ? Colors.red.shade700 : Colors.green.shade700, 
                      isMoney: true), 
                  _buildDetailRow(Icons.local_shipping, 'Proveedor', producto.proveedor),
                  _buildDetailRow(Icons.calendar_today, 'Fecha Ingreso', producto.fechaIngreso ?? 'N/A'),
                  _buildDetailRow(
                    producto.activo ? Icons.check_circle : Icons.cancel, 
                    'Estado', 
                    producto.activo ? 'Activo' : 'Inactivo',
                    color: producto.activo ? Colors.green : Colors.red
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para diseño de filas (MEJORADO con Card)
  Widget _buildDetailRow(IconData icon, String label, String value, {Color? color, bool isMoney = false}) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blueGrey, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: isMoney ? FontWeight.bold : FontWeight.normal,
                      color: color ?? Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}