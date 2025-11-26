import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ferremateriales/features/productos/model/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/product_model.dart';
part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  List<ProductModel> _productosCache = [];
  List<ProductModel> _destacados = [];
  Map<int, List<ProductModel>> _productosPorCategoria = {};
  bool _todosLosProductosCargados = false;

  ProductBloc() : super(ProductInitial()) {
    on<CargarDestacados>(_onCargarDestacados);
    on<CargarTodosLosProductos>(_onCargarTodosLosProductos);
    on<ProductBuscarPorNombre>(_onBuscarProductoPorNombre);
    on<ProductFilterByCategory>(_onFilterByCategory);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  // ============================================================
  // 1) SOLO CARGAR LOS 8 DESTACADOS PARA HOME
  // ============================================================
  Future<void> _onCargarDestacados(
      CargarDestacados event, Emitter<ProductState> emit) async {

    emit(ProductLoadInProgress());

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/v1/products'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          _destacados = decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => ProductModel.fromJson(item))
              .toList();

          emit(ProductDestacadosSuccess(_destacados));
          return;
        }
      }

      emit(const ProductLoadFailure("Error cargando destacados"));
    } catch (e) {
      emit(const ProductLoadFailure("Error de conexión"));
    }
  }

  // ============================================================
  // 2) Cargar todos los productos (solo búsqueda)
  // ============================================================
  Future<void> _onCargarTodosLosProductos(
      CargarTodosLosProductos event, Emitter<ProductState> emit) async {

    emit(ProductLoadInProgress());

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/v1/products/all_products'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          _productosCache = decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => ProductModel.fromJson(item))
              .toList();

          _todosLosProductosCargados = true;
          debugPrint('ProductBloc - CargarTodos: cache filled with ${_productosCache.length} products');
          emit(ProductLoadSuccess(_productosCache));
          return;
        }
      }

      emit(const ProductLoadFailure("Error cargando productos"));
    } catch (e) {
      emit(const ProductLoadFailure("Error de conexión"));
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
      emit(ProductLoadSuccess(_productosCache));
      return;
    }

    final resultados = _productosCache.where((product) {
      return product.nombre?.toLowerCase().contains(query) ?? false;
    }).toList();

    debugPrint('ProductBloc - search results: ${resultados.length}');
    emit(ProductLoadSuccess(resultados));
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
        'http://localhost:3000/api/v1/products?category_id=${event.categoryId}',
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
  void _onToggleFavorite(
      ToggleFavorite event, Emitter<ProductState> emit) {

    if (state is! ProductLoadSuccess &&
        state is! ProductDestacadosSuccess) return;

    // Actualiza todos y destacados
    _productosCache = _productosCache.map((p) {
      if (p.id == event.productId) {
        return p.copyWith(isFavorite: !p.isFavorite);
      }
      return p;
    }).toList();

    _destacados = _destacados.map((p) {
      if (p.id == event.productId) {
        return p.copyWith(isFavorite: !p.isFavorite);
      }
      return p;
    }).toList();

    // Reemitir según estado actual
    if (state is ProductDestacadosSuccess) {
      emit(ProductDestacadosSuccess(_destacados));
    } else {
      emit(ProductLoadSuccess(_productosCache));
    }
  }
}
