import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ferremateriales/core/config/api_config.dart';
import 'package:ferremateriales/features/productos/model/product_model.dart';
import 'package:ferremateriales/features/productos/services/favorites_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
  }

  // Helper para marcar productos como favoritos
  List<ProductModel> _markFavorites(List<ProductModel> products) {
    return products.map((p) {
      return p.copyWith(isFavorite: _favoritesService.isFavoriteCached(p.id ?? 0));
    }).toList();
  }

  // ============================================================
  // 1) SOLO CARGAR LOS 8 DESTACADOS PARA HOME
  // ============================================================
  Future<void> _onCargarDestacados(
      CargarDestacados event, Emitter<ProductState> emit) async {

    print("=== CARGAR DESTACADOS INICIADO ===");
    emit(ProductLoadInProgress());

    try {
      final url = Uri.parse(ApiConfig.productsUrl);
      print("URL destacados: $url");
      
      print("Enviando petición HTTP GET...");
      final response = await http.get(
        url,
        headers: ApiConfig.headers,
      );

      print("Status code: ${response.statusCode}");
      print("Response body (primeros 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}");

      if (response.statusCode == 200) {
        // Verificar si la respuesta es HTML (error de ngrok)
        if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
          print("❌ ERROR: El servidor respondió con HTML en lugar de JSON");
          print("Esto puede ser porque:");
          print("1. La URL de ngrok es incorrecta");
          print("2. El servidor no está corriendo en el puerto 3000");
          print("3. El endpoint /api/v1/products no existe");
          emit(const ProductLoadFailure("Error: Servidor respondió con HTML. Verifica la URL de ngrok y que el backend esté corriendo."));
          return;
        }

        final decoded = jsonDecode(response.body);
        print("Tipo de respuesta: ${decoded.runtimeType}");

        if (decoded is List) {
          print("Cantidad de items en respuesta: ${decoded.length}");
          
          _destacados = decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => ProductModel.fromJson(item))
              .toList();

          // Marcar favoritos
          _destacados = _markFavorites(_destacados);

          print("✅ Destacados cargados: ${_destacados.length} productos");
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
      print("Stack trace: ${StackTrace.current}");
      emit(ProductLoadFailure("Error de conexión: ${e.toString()}"));
    }
  }

  // ============================================================
  // 2) Cargar todos los productos (solo búsqueda)
  // ============================================================
  Future<void> _onCargarTodosLosProductos(
      CargarTodosLosProductos event, Emitter<ProductState> emit) async {

    print("=== CARGAR TODOS LOS PRODUCTOS INICIADO ===");
    emit(ProductLoadInProgress());

    try {
      final url = Uri.parse(ApiConfig.allProductsUrl);
      print("URL todos los productos: $url");
      
      print("Enviando petición HTTP GET...");
      final response = await http.get(
        url,
        headers: ApiConfig.headers,
      );

      print("Status code: ${response.statusCode}");
      print("Response body (primeros 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}");

      if (response.statusCode == 200) {
        // Verificar si la respuesta es HTML (error de ngrok)
        if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
          print("❌ ERROR: El servidor respondió con HTML en lugar de JSON");
          print("Esto puede ser porque:");
          print("1. La URL de ngrok es incorrecta");
          print("2. El servidor no está corriendo en el puerto 3000");
          print("3. El endpoint /api/v1/products/all_products no existe");
          emit(const ProductLoadFailure("Error: Servidor respondió con HTML. Verifica la URL de ngrok y que el backend esté corriendo."));
          return;
        }

        final decoded = jsonDecode(response.body);
        print("Tipo de respuesta: ${decoded.runtimeType}");

        if (decoded is List) {
          print("Cantidad de items en respuesta: ${decoded.length}");
          
          _productosCache = decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => ProductModel.fromJson(item))
              .toList();

          // Marcar favoritos
          _productosCache = _markFavorites(_productosCache);

          _todosLosProductosCargados = true;
          print('✅ ProductBloc - CargarTodos: cache filled with ${_productosCache.length} products');
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
      ProductBuscarPorNombre event, Emitter<ProductState> emit) {

    final query = event.nombre.toLowerCase().trim();
    debugPrint('ProductBloc - buscar query="$query", cacheSize=${_productosCache.length}');

    if (query.isEmpty) {
      // Marcar favoritos antes de emitir
      final productos = _markFavorites(_productosCache);
      emit(ProductLoadSuccess(productos));
      return;
    }

    final resultados = _productosCache.where((product) {
      return product.nombre?.toLowerCase().contains(query) ?? false;
    }).toList();

    // Marcar favoritos en los resultados
    final resultadosConFavoritos = _markFavorites(resultados);

    debugPrint('ProductBloc - search results: ${resultadosConFavoritos.length}');
    emit(ProductLoadSuccess(resultadosConFavoritos));
  }

  // ============================================================
  // 4) Filtrar por categoría
  // ============================================================
  Future<void> _onFilterByCategory(
      ProductFilterByCategory event, Emitter<ProductState> emit) async {

    // Si ya tenemos los productos cargados, filtrar localmente
    if (_todosLosProductosCargados && _productosCache.isNotEmpty) {
      debugPrint('ProductBloc - Filtrando categoría ${event.categoryId} desde caché');
      
      final filtered = _productosCache.where((product) {
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
      final response = await http.get(Uri.parse(
        ApiConfig.productsByCategoryUrl(event.categoryId),
      ));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          final filtered = decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => ProductModel.fromJson(item))
              .toList();

          _productosPorCategoria[event.categoryId] = filtered;
          debugPrint('ProductBloc - Categoría ${event.categoryId} cargada con ${filtered.length} productos');
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
      ToggleFavorite event, Emitter<ProductState> emit) async {

    if (state is! ProductLoadSuccess &&
        state is! ProductDestacadosSuccess) return;

    // Actualizar el servicio de favoritos
    _favoritesService.toggleFavoriteCache(event.productId);

    // Actualiza todos y destacados usando _markFavorites
    _productosCache = _markFavorites(_productosCache);
    _destacados = _markFavorites(_destacados);

    // Reemitir según estado actual
    if (state is ProductDestacadosSuccess) {
      emit(ProductDestacadosSuccess(_destacados));
    } else {
      emit(ProductLoadSuccess(_productosCache));
    }
  }
}
