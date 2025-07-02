import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductService {
  Future<List<dynamic>> fetchProductos() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/v1/productos'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar productos');
    }
  }
}