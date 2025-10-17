import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/inventario_service.dart';
import 'agregar_productos.dart';
import 'detalle_producto.dart'; 

class ListaProductosScreen extends StatefulWidget {
  const ListaProductosScreen({super.key});

  @override
  State<ListaProductosScreen> createState() => _ListaProductosScreenState();
}

class _ListaProductosScreenState extends State<ListaProductosScreen> {
  late Future<List<Producto>> _productosFuture;
  final InventarioService _inventarioService = InventarioService();

  @override
  void initState() {
    super.initState();
    _fetchProductos();
  }

  void _fetchProductos() {
    setState(() {
      _productosFuture = _inventarioService.obtenerProductos();
    });
  }

  void _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarProductoScreen()),
    );
    if (result == true) {
      _fetchProductos();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definimos un color sutil para el indicador de bajo stock
    final Color lowStockColor = Colors.orange.shade50; 
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario de Productos'),
        elevation: 4, // Añadir sombra al AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProductos,
          ),
        ],
      ),
      body: FutureBuilder<List<Producto>>(
        future: _productosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos registrados.'));
          } else {
            final productos = snapshot.data!;
            return ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                
                final bool lowStock = producto.stock < 5;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    // Usar un color sutil como fondo si hay poco stock
                    color: lowStock ? lowStockColor : Theme.of(context).cardColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Bordes redondeados
                      side: lowStock ? BorderSide(color: Colors.orange.shade200, width: 1) : BorderSide.none,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: lowStock ? Colors.orange.shade700 : Theme.of(context).primaryColor,
                        child: Text(
                          producto.stock.toString(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      title: Text(
                        producto.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Categoría: ${producto.categoria}'),
                          Text(
                            'Precio: \$${producto.precio.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                      isThreeLine: false, // Ahora es de dos líneas
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalleProductoScreen(producto: producto),
                          ),
                        ).then((refresh) {
                          if (refresh == true) {
                            _fetchProductos();
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}