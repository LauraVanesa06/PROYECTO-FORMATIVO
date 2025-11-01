import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CartService {
  final String baseUrl = 'http://localhost:3000';
  final storage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('No token found');

      print('Using token: $token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/cart_items'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else if (response.statusCode == 401) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'No autorizado: Inicie sesión nuevamente');
      } else {
        throw Exception('Error al cargar el carrito');
      }
    } catch (e) {
      print('Error loading cart items: $e');
      rethrow;
    }
  }
}
