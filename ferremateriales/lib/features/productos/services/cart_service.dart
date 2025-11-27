import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ferremateriales/features/productos/models/cart_item_model.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final String baseUrl = 'http://localhost:3000';
  final storage = const FlutterSecureStorage();
  
  List<CartItemModel> _cartCache = [];
  bool _cacheLoaded = false;

  bool get isCacheLoaded => _cacheLoaded;
  List<CartItemModel> get cartCache => _cartCache;

  

  Future<void> loadCartCache() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/cart_items'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cartCache = data.map((item) => CartItemModel.fromJson(item)).toList();
        _cacheLoaded = true;
      }
    } catch (e) {
      print('Error loading cart cache: $e');
    }
  }

  Future<List<CartItemModel>> getCartItems() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/cart_items'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cartCache = data.map((item) => CartItemModel.fromJson(item)).toList();
        _cacheLoaded = true;
        return _cartCache;
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

  Future<void> increaseQuantity(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/v1/cart_items/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'quantity_action': 'increase'}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al aumentar cantidad');
    }
    // Recargar caché después de actualizar
    await loadCartCache();
  }


  Future<void> decreaseQuantity(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/v1/cart_items/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'quantity_action': 'decrease'}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al disminuir cantidad');
    }
    // Recargar caché después de actualizar
    await loadCartCache();
  }

  Future<void> removeItem(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/v1/cart_items/$id'));
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar producto del carrito');
    }
    // Recargar caché después de eliminar
    await loadCartCache();
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
    
    // Recargar caché después de agregar
    await loadCartCache();
  }
}
 