import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/inventario_service.dart';

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final InventarioService _inventarioService = InventarioService();

  // Controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _codigoBarrasController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController(text: '0'); // Default 0
  final TextEditingController _proveedorController = TextEditingController();

  void _guardarProducto() async {
    if (_formKey.currentState!.validate()) {
      try {
        final nuevoProducto = Producto(
          nombre: _nombreController.text,
          descripcion: _descripcionController.text.isEmpty ? '' : _descripcionController.text,
          codigoBarras: _codigoBarrasController.text,
          categoria: _categoriaController.text.isEmpty ? 'Sin Categoría' : _categoriaController.text,
          precio: double.parse(_precioController.text),
          stock: int.parse(_stockController.text),
          proveedor: _proveedorController.text.isEmpty ? 'Desconocido' : _proveedorController.text,
          activo: true, 
        );

        await _inventarioService.agregarProducto(nuevoProducto);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Producto agregado con éxito!')),
        );
        Navigator.pop(context, true); 

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al agregar producto: ${e.toString()}')),
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
        title: const Text('Agregar Nuevo Producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextFormField(_nombreController, 'Nombre del Producto', Icons.inventory_2),
              _buildTextFormField(_descripcionController, 'Descripción', Icons.description, isOptional: true),
              _buildTextFormField(_codigoBarrasController, 'Código de Barras (UNIQUE)', Icons.qr_code_scanner),
              _buildTextFormField(_categoriaController, 'Categoría', Icons.category, isOptional: true),

              _buildTextFormField(_precioController, 'Precio (\$)', Icons.attach_money, isNumeric: true, isDecimal: true),
              _buildTextFormField(_stockController, 'Stock / Cantidad', Icons.format_list_numbered, isNumeric: true, isOptional: true),
              _buildTextFormField(_proveedorController, 'Proveedor', Icons.local_shipping, isOptional: true),
              
              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: _guardarProducto,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR PRODUCTO', style: TextStyle(fontSize: 18)),
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

  // Widget auxiliar para diseño responsivo y validación
 Widget _buildTextFormField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumeric = false,
    bool isDecimal = false,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0), // Menos espacio entre campos
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
          // Mostrar un asterisco para campos obligatorios
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