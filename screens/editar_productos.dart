import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/inventario_service.dart';

class EditarProductoScreen extends StatefulWidget {
  final Producto producto;
  const EditarProductoScreen({super.key, required this.producto});

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final InventarioService _inventarioService = InventarioService();

  // Controladores inicializados con los datos del producto
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _codigoBarrasController;
  late final TextEditingController _categoriaController;
  late final TextEditingController _precioController;
  late final TextEditingController _stockController;
  late final TextEditingController _proveedorController;
  late bool _activo;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _descripcionController = TextEditingController(text: widget.producto.descripcion);
    _codigoBarrasController = TextEditingController(text: widget.producto.codigoBarras);
    _categoriaController = TextEditingController(text: widget.producto.categoria);
    _precioController = TextEditingController(text: widget.producto.precio.toStringAsFixed(2));
    _stockController = TextEditingController(text: widget.producto.stock.toString());
    _proveedorController = TextEditingController(text: widget.producto.proveedor);
    _activo = widget.producto.activo;
  }

  void _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      try {
        final productoActualizado = Producto(
          id: widget.producto.id, // ID es crucial para el UPDATE
          nombre: _nombreController.text,
          descripcion: _descripcionController.text.isEmpty ? '' : _descripcionController.text,
          codigoBarras: _codigoBarrasController.text.isEmpty ? widget.producto.codigoBarras : _codigoBarrasController.text,
          categoria: _categoriaController.text.isEmpty ? 'Sin Categoría' : _categoriaController.text,
          precio: double.parse(_precioController.text),
          stock: int.parse(_stockController.text),
          proveedor: _proveedorController.text.isEmpty ? 'Desconocido' : _proveedorController.text,
          activo: _activo,
        );

        // Llamada al servicio de ACTUALIZAR
        await _inventarioService.actualizarProducto(productoActualizado);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✏️ Producto actualizado con éxito!')),
        );
        // Regresar a la pantalla anterior (detalle), indicando que hubo un cambio
        Navigator.pop(context, true); 
        
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al actualizar producto: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _codigoBarrasController.dispose();
    _categoriaController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _proveedorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar: ${widget.producto.nombre}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Usamos el widget auxiliar de la pantalla de agregar producto
              _buildTextFormField(_nombreController, 'Nombre del Producto', Icons.inventory_2),
              _buildTextFormField(_descripcionController, 'Descripción', Icons.description, isOptional: true),
              _buildTextFormField(_codigoBarrasController, 'Código de Barras (UNIQUE)', Icons.qr_code_scanner), 
              _buildTextFormField(_categoriaController, 'Categoría', Icons.category, isOptional: true),

              _buildTextFormField(_precioController, 'Precio (\$)', Icons.attach_money, isNumeric: true, isDecimal: true),
              _buildTextFormField(_stockController, 'Stock / Cantidad', Icons.format_list_numbered, isNumeric: true, isOptional: true),
              _buildTextFormField(_proveedorController, 'Proveedor', Icons.local_shipping, isOptional: true),

              // Switch para Activo/Inactivo
              SwitchListTile(
                title: const Text('Producto Activo'),
                value: _activo,
                onChanged: (bool value) {
                  setState(() {
                    _activo = value;
                  });
                },
                secondary: Icon(_activo ? Icons.check_circle : Icons.cancel, color: _activo ? Colors.green : Colors.red),
              ),

              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: _guardarCambios,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR CAMBIOS', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget auxiliar para diseño responsivo y validación (copia de agregar_producto)
  Widget _buildTextFormField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumeric = false,
    bool isDecimal = false,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric 
            ? (isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number) 
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          // MEJORA VISUAL: Bordes redondeados y relleno
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100, // Color de relleno sutil
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          hintText: isOptional ? '' : 'Obligatorio *', 
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Este campo es obligatorio.';
          }
          if (isNumeric && value != null && value.isNotEmpty) {
            final parsedValue = isDecimal ? double.tryParse(value) : int.tryParse(value);
            if (parsedValue == null) {
              return 'Ingrese un número válido.';
            }
          }
          return null;
        },
      ),
    );
  }
}