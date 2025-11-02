import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FavoritesService {
  final String baseUrl = 'http://localhost:3000';
  final storage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('No token found');

      print('Using token: $token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/favorites'),
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
        throw Exception('Error al cargar favoritos');
      }
    } catch (e) {
      print('Error loading favorites: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(int productId) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('No token found');

    final url = Uri.parse('$baseUrl/api/v1/favorites/$productId');

    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Error al eliminar favorito");
    }
  }

  Future<void> addToCart(int productId) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('No token found');

    final url = Uri.parse('$baseUrl/api/v1/cart_items');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "product_id": productId,
        "cantidad": 1,
      }),
    );

    print('addToCart status: ${response.statusCode}');
    print('addToCart body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception("Error al agregar al carrito");
    }
  }

}