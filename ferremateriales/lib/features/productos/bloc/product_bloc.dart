import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ferremateriales/core/config/api_config.dart';
import 'package:ferremateriales/features/productos/model/product_model.dart';
import 'package:ferremateriales/features/productos/services/favorites_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  List<ProductModel> _productosCache = [];
  List<ProductModel> _destacados = [];
  Map<int, List<ProductModel>> _productosPorCategoria = {};
  bool _todosLosProductosCargados = false;
  final FavoritesService _favoritesService = FavoritesService();

  ProductBloc() : super(ProductInitial()) {
    on<CargarDestacados>(_onCargarDestacados);
    on<CargarTodosLosProductos>(_onCargarTodosLosProductos);
    on<ProductBuscarPorNombre>(_onBuscarProductoPorNombre);
    on<ProductFilterByCategory>(_onFilterByCategory);
    on<ToggleFavorite>(_onToggleFavorite);
    
    // Cargar destacados desde cache persistente al iniciar
    _loadDestacadosFromCache();
  }

  // Cargar destacados desde SharedPreferences
  Future<void> _loadDestacadosFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('destacados_cache');
      
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        _destacados = decoded.map((item) => ProductModel.fromJson(item)).toList();
        _destacados = _markFavorites(_destacados);
        print("💾 Cache de destacados cargado: ${_destacados.length} productos");
      }
    } catch (e) {
      print("⚠️ Error cargando cache de destacados: $e");
    }
  }

  // Guardar destacados en SharedPreferences
  Future<void> _saveDestacadosToCache(List<ProductModel> productos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(productos.map((p) => p.toJson()).toList());
      await prefs.setString('destacados_cache', jsonData);
      print("💾 Destacados guardados en cache: ${productos.length} productos");
    } catch (e) {
      print("⚠️ Error guardando cache de destacados: $e");
    }
  }

  // Helper para marcar productos como favoritos
  List<ProductModel> _markFavorites(List<ProductModel> products) {
    return products.map((p) {
      return p.copyWith(
        isFavorite: _favoritesService.isFavoriteCached(p.id ?? 0),
      );
    }).toList();
  }

  // ============================================================
  // 1) SOLO CARGAR LOS 8 DESTACADOS PARA HOME (MÁS VENDIDOS)
  // ============================================================
  Future<void> _onCargarDestacados(
    CargarDestacados event,
    Emitter<ProductState> emit,
  ) async {
    print("=== CARGAR DESTACADOS INICIADO ===");

    // 🔹 Si ya tenemos destacados en caché, emitirlos INMEDIATAMENTE
    if (_destacados.isNotEmpty) {
      print("✅ Emitiendo destacados desde cache (${_destacados.length} productos)");
      emit(ProductDestacadosSuccess(_destacados));
      
      // Si NO es refresh forzado, terminar aquí (usar solo cache)
      if (!event.forceRefresh) {
        print("💾 Usando solo cache, sin petición HTTP");
        return;
      }
      
      // Si ES refresh forzado, continuar para actualizar en background
      print("🔄 Actualizando destacados en background...");
    } else {
      // No hay cache, mostrar loading
      emit(ProductLoadInProgress());
    }

    // 🔹 Hacer petición al backend
    try {
      final url = Uri.parse(ApiConfig.productsUrl);
      print("URL destacados (más vendidos): $url");

      print("Enviando petición HTTP GET...");
      final response = await http.get(url, headers: ApiConfig.headers);

      print("Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Verificar si la respuesta es HTML (error de ngrok)
        if (response.body.trim().startsWith('<!DOCTYPE') ||
            response.body.trim().startsWith('<html')) {
          print("❌ ERROR: El servidor respondió con HTML en lugar de JSON");
          
          // Si hay cache, mantenerlo y no mostrar error
          if (_destacados.isNotEmpty) {
            print("💾 Manteniendo cache antiguo");
            return;
          }
          
          emit(
            const ProductLoadFailure(
              "Error: Servidor respondió con HTML. Verifica la URL de ngrok y que el backend esté corriendo.",
            ),
          );
          return;
        }

        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          print(
            "Cantidad de productos destacados (más vendidos): ${decoded.length}",
          );

          _destacados =
              decoded
                  .whereType<Map<String, dynamic>>()
                  .map((item) => ProductModel.fromJson(item))
                  .toList();

          // Marcar favoritos
          _destacados = _markFavorites(_destacados);
          
          // Guardar en cache persistente
          await _saveDestacadosToCache(_destacados);

          print(
            "✅ Destacados cargados: ${_destacados.length} productos más vendidos",
          );
          emit(ProductDestacadosSuccess(_destacados));
          return;
        } else {
          print("❌ ERROR: La respuesta no es una lista");
        }
      } else {
        print("❌ ERROR: Status code ${response.statusCode}");
        print("Response body: ${response.body}");
      }

      emit(const ProductLoadFailure("Error cargando destacados"));
    } catch (e) {
      print("❌ EXCEPCIÓN en _onCargarDestacados: $e");
      emit(ProductLoadFailure("Error de conexión: ${e.toString()}"));
    }
  }

  // ============================================================
  // 2) Cargar todos los productos (solo búsqueda)
  // ============================================================
  Future<void> _onCargarTodosLosProductos(
    CargarTodosLosProductos event,
    Emitter<ProductState> emit,
  ) async {
    print("=== CARGAR TODOS LOS PRODUCTOS INICIADO ===");

    // 🔹 Si ya tenemos productos en caché, emitirlos inmediatamente
    if (_productosCache.isNotEmpty) {
      print(
        "✅ Usando caché de productos (${_productosCache.length} productos)",
      );
      emit(ProductLoadSuccess(_productosCache));
      return;
    }

    emit(ProductLoadInProgress());

    try {
      final url = Uri.parse(ApiConfig.allProductsUrl);
      print("URL todos los productos: $url");

      print("Enviando petición HTTP GET...");
      final response = await http.get(url, headers: ApiConfig.headers);

      print("Status code: ${response.statusCode}");
      print(
        "Response body (primeros 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}",
      );

      if (response.statusCode == 200) {
        // Verificar si la respuesta es HTML (error de ngrok)
        if (response.body.trim().startsWith('<!DOCTYPE') ||
            response.body.trim().startsWith('<html')) {
          print("❌ ERROR: El servidor respondió con HTML en lugar de JSON");
          print("Esto puede ser porque:");
          print("1. La URL de ngrok es incorrecta");
          print("2. El servidor no está corriendo en el puerto 3000");
          print("3. El endpoint /api/v1/products/all_products no existe");
          emit(
            const ProductLoadFailure(
              "Error: Servidor respondió con HTML. Verifica la URL de ngrok y que el backend esté corriendo.",
            ),
          );
          return;
        }

        final decoded = jsonDecode(response.body);
        print("Tipo de respuesta: ${decoded.runtimeType}");

        if (decoded is List) {
          print("Cantidad de items en respuesta: ${decoded.length}");

          _productosCache =
              decoded
                  .whereType<Map<String, dynamic>>()
                  .map((item) => ProductModel.fromJson(item))
                  .toList();

          // Marcar favoritos
          _productosCache = _markFavorites(_productosCache);

          _todosLosProductosCargados = true;
          print(
            '✅ ProductBloc - CargarTodos: cache filled with ${_productosCache.length} products',
          );
          emit(ProductLoadSuccess(_productosCache));
          return;
        } else {
          print("❌ ERROR: La respuesta no es una lista");
        }
      } else {
        print("❌ ERROR: Status code ${response.statusCode}");
        print("Response body: ${response.body}");
      }

      emit(const ProductLoadFailure("Error cargando productos"));
    } catch (e) {
      print("❌ EXCEPCIÓN en _onCargarTodosLosProductos: $e");
      print("Stack trace: ${StackTrace.current}");
      emit(ProductLoadFailure("Error de conexión: ${e.toString()}"));
    }
  }

  // ============================================================
  // 3) Buscar por nombre (solo sobre productosCache)
  // ============================================================
  void _onBuscarProductoPorNombre(
    ProductBuscarPorNombre event,
    Emitter<ProductState> emit,
  ) {
    final query = event.nombre.toLowerCase().trim();
    debugPrint(
      'ProductBloc - buscar query="$query", cacheSize=${_productosCache.length}',
    );

    if (query.isEmpty) {
      // Marcar favoritos antes de emitir
      final productos = _markFavorites(_productosCache);
      emit(ProductLoadSuccess(productos));
      return;
    }

    final resultados =
        _productosCache.where((product) {
          return product.nombre?.toLowerCase().contains(query) ?? false;
        }).toList();

    // Marcar favoritos en los resultados
    final resultadosConFavoritos = _markFavorites(resultados);

    debugPrint(
      'ProductBloc - search results: ${resultadosConFavoritos.length}',
    );
    emit(ProductLoadSuccess(resultadosConFavoritos));
  }

  // ============================================================
  // 4) Filtrar por categoría
  // ============================================================
  Future<void> _onFilterByCategory(
    ProductFilterByCategory event,
    Emitter<ProductState> emit,
  ) async {
    // Si ya tenemos los productos cargados, filtrar localmente
    if (_todosLosProductosCargados && _productosCache.isNotEmpty) {
      debugPrint(
        'ProductBloc - Filtrando categoría ${event.categoryId} desde caché',
      );

      final filtered =
          _productosCache.where((product) {
            return product.categoryId == event.categoryId;
          }).toList();

      _productosPorCategoria[event.categoryId] = filtered;
      emit(ProductLoadSuccess(filtered));
      return;
    }

    // Si ya está en caché de categoría, usar ese
    if (_productosPorCategoria.containsKey(event.categoryId)) {
      debugPrint('ProductBloc - Usando caché de categoría ${event.categoryId}');
      emit(ProductLoadSuccess(_productosPorCategoria[event.categoryId]!));
      return;
    }

    emit(ProductLoadInProgress());

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.productsByCategoryUrl(event.categoryId)),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          final filtered =
              decoded
                  .whereType<Map<String, dynamic>>()
                  .map((item) => ProductModel.fromJson(item))
                  .toList();

          _productosPorCategoria[event.categoryId] = filtered;
          debugPrint(
            'ProductBloc - Categoría ${event.categoryId} cargada con ${filtered.length} productos',
          );
          emit(ProductLoadSuccess(filtered));
          return;
        }
      }

      emit(const ProductLoadFailure("Error cargando categoría"));
    } catch (e) {
      emit(const ProductLoadFailure("Error de conexión"));
    }
  }

  // ============================================================
  // 5) Toggle favorito
  // ============================================================
  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<ProductState> emit,
  ) async {
    // Actualizar el servicio de favoritos primero
    _favoritesService.toggleFavoriteCache(event.productId);

    // Actualizar todos los cachés con el nuevo estado de favoritos
    _productosCache = _markFavorites(_productosCache);
    _destacados = _markFavorites(_destacados);
    
    // Actualizar cada categoría en caché
    _productosPorCategoria = _productosPorCategoria.map(
      (key, value) => MapEntry(key, _markFavorites(value)),
    );

    // Reemitir según el estado actual sin recargar
    if (state is ProductDestacadosSuccess) {
      emit(ProductDestacadosSuccess(_destacados));
    } else if (state is ProductLoadSuccess) {
      final currentProducts = (state as ProductLoadSuccess).productos;
      // Re-marcar los productos actuales mostrados
      final updatedProducts = _markFavorites(currentProducts);
      emit(ProductLoadSuccess(updatedProducts));
    }
  }
}
