import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final String baseUrl = 'http://localhost:3000';
  final storage = const FlutterSecureStorage();

  List<int> _favoriteProductIds = [];
  List<Map<String, dynamic>> _favoritesCache = [];
  bool _cacheLoaded = false;

  // Método para limpiar el caché y forzar recarga
  void clearCache() {
    _favoriteProductIds = [];
    _favoritesCache = [];
    _cacheLoaded = false;
  }

  Future<void> loadFavoritesCache({bool force = false}) async {
    // Si ya está cargado y no se fuerza, retornar
    if (_cacheLoaded && !force) return;

    final token = await storage.read(key: 'auth_token');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/favorites'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _favoritesCache = List<Map<String, dynamic>>.from(data);
      _favoriteProductIds = data
          .map((f) => f['product_id'])
          .where((id) => id != null)
          .map<int>((id) => id as int)
          .toList();
      _cacheLoaded = true;
    }
  }

  // Método para refrescar favoritos desde el servidor (pull-to-refresh)
  Future<void> refreshFavorites() async {
    await loadFavoritesCache(force: true);
  }

  bool isFavoriteCached(int productId) => _favoriteProductIds.contains(productId);

  void toggleFavoriteCache(int productId) {
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
  }

  List<int> get favoriteIds => _favoriteProductIds;
  bool get isCacheLoaded => _cacheLoaded;
  List<Map<String, dynamic>> get favoritesCache => _favoritesCache;

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

  Future<bool> isFavorite(int productId) async {
    // Usar caché local en lugar de petición HTTP
    return isFavoriteCached(productId);
  }


  Future<void> toggleFavorite(int productId) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('No token found');

    final url = Uri.parse('$baseUrl/api/v1/favorites/$productId');

    // Primero intenta eliminar (si ya es favorito)
    final deleteResponse = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    // Si el DELETE fue exitoso, recargar caché y retornar
    if (deleteResponse.statusCode == 200) {
      await loadFavoritesCache();
      return;
    }

    // Si no existía, intenta agregar
    final postResponse = await http.post(
      Uri.parse('$baseUrl/api/v1/favorites'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"product_id": productId}),
    );

    if (postResponse.statusCode != 201) {
      throw Exception("Error al agregar/eliminar favorito");
    }
    
    // Recargar caché después de agregar
    await loadFavoritesCache();
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