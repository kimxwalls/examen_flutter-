import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class InventarioService {
   // URL FINAL CORREGIDA: Usa el puerto 8080 para la ejecución en web (navegador)
   final String _baseUrl = 'http://localhost:8080/API_INVENTARIO/api.php'; 

   Future<List<Producto>> obtenerProductos() async {
     final url = Uri.parse('$_baseUrl?action=productos');
    final response = await http.get(url);

    if (response.statusCode == 200) {
     final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List).map((json) => Producto.fromJson(json)).toList();
        } else {
        throw Exception('Error de API al listar: ${data['message']}');
        }
      } else {
      throw Exception('Fallo la conexión (READ): ${response.statusCode}');
    }
 }

  Future<bool> agregarProducto(Producto producto) async {
    final url = Uri.parse('$_baseUrl?action=crear');
    final response = await http.post(
      url,
       headers: {'Content-Type': 'application/json'},
     body: json.encode(producto.toJson()),
    );
     return _handleResponse(response);
  }

  // MÉTODO CRUCIAL PARA LA EDICIÓN
   Future<bool> actualizarProducto(Producto producto) async {
     final url = Uri.parse('$_baseUrl?action=update');
    final response = await http.post(
     url, 
       headers: {'Content-Type': 'application/json'},
      body: json.encode(producto.toJson()), // Envía el Producto completo, incluyendo el ID
    );
    return _handleResponse(response);
  }

  // MÉTODO CRUCIAL PARA LA ELIMINACIÓN
  Future<bool> eliminarProducto(int id) async {
     final url = Uri.parse('$_baseUrl?action=delete');
    final response = await http.post(
     url, 
       headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id}), // Envía solo el ID en el cuerpo JSON
    );
    return _handleResponse(response);
  }
 
 // Función auxiliar para manejar la respuesta del backend PHP
 bool _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
       final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
        return true;
        } else {
          throw Exception('Error de API: ${data['message']}');
           }
           } else {
            throw Exception('Fallo la conexión. Código: ${response.statusCode}');
             }
 }
}