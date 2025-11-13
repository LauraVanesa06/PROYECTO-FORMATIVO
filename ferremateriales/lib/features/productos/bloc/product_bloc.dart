import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import '../model/product_model.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  bool _yaCargados = false; // 🔒 Control interno para evitar recargar
  List<ProductModel> _productosCache = []; // 🧠 Guardamos la lista localmente

  ProductBloc() : super(ProductInitial()) {
    on<ProductEntrarPressed>(_onLoadProducts);
    on<ToggleFavorite>(_onToggleFavorite);
    on<ProductFilterByCategory>(_onFilterByCategory);
    on<ProductBuscarPorNombre>(_onBuscarProductoPorNombre);
  }

  // ✅ Cargar productos (solo si no se ha hecho antes)
  Future<void> _onLoadProducts(
      ProductEntrarPressed event, Emitter<ProductState> emit) async {
    if (_yaCargados && _productosCache.isNotEmpty) {
      emit(ProductLoadSuccess(_productosCache));
      return;
    }

    emit(ProductLoadInProgress());

    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/api/v1/products'));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          final products = decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => ProductModel.fromJson(item))
              .toList();

          _productosCache = products;
          _yaCargados = true;
          emit(ProductLoadSuccess(products));
        } else {
          emit(ProductLoadFailure());
        }
      } else {
        emit(ProductLoadFailure());
      }
    } catch (e) {
      emit(ProductLoadFailure());
    }
  }

  // 🔍 Filtrar productos por categoría (por ID)
  Future<void> _onFilterByCategory(
      ProductFilterByCategory event, Emitter<ProductState> emit) async {
    emit(ProductLoadInProgress());

    try {
      // ✅ Llamamos al backend con category_id en lugar de category
      final response = await http.get(Uri.parse(
          'http://localhost:3000/api/v1/products?category_id=${event.categoryId}'));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          final products = decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => ProductModel.fromJson(item))
              .toList();
          emit(ProductLoadSuccess(products));
        } else {
          emit(ProductLoadFailure());
        }
      } else {
        emit(ProductLoadFailure());
      }
    } catch (e) {
      print('❌ Error filtrando productos por categoría: $e');
      emit(ProductLoadFailure());
    }
  }

  // ❤️ Marcar/desmarcar favoritos
  void _onToggleFavorite(ToggleFavorite event, Emitter<ProductState> emit) {
    if (state is ProductLoadSuccess) {
      final currentState = state as ProductLoadSuccess;

      final updatedProducts = currentState.productos.map((product) {
        if (product.id == event.productId) {
          return product.copyWith(isFavorite: !product.isFavorite);
        }
        return product;
      }).toList();

      _productosCache = updatedProducts;
      emit(ProductLoadSuccess(updatedProducts));
    }
  }

  // 🔎 Buscar productos por nombre (consultando todos los productos del backend)
  Future<void> _onBuscarProductoPorNombre(
      ProductBuscarPorNombre event, Emitter<ProductState> emit) async {
    final query = event.query.toLowerCase().trim();

    if (query.isEmpty) {
      // Si el texto está vacío, mostramos todos los productos
      emit(ProductLoadSuccess(_productosCache));
      return;
    }

    emit(ProductLoadInProgress());

    try {
      // ✅ Si aún no tenemos todos los productos, los traemos desde el backend
      if (_productosCache.isEmpty) {
        final response = await http.get(
            Uri.parse('http://localhost:3000/api/v1/products/all_products'));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded is List) {
            _productosCache = decoded
                .whereType<Map<String, dynamic>>()
                .map((item) => ProductModel.fromJson(item))
                .toList();
          }
        }
      }

      // 🔍 Filtramos los productos por nombre (en la lista completa)
      final resultados = _productosCache.where((producto) {
        return producto.nombre!.toLowerCase().contains(query);
      }).toList();

      emit(ProductLoadSuccess(resultados));
    } catch (e) {
      print('❌ Error buscando productos: $e');
      emit(ProductLoadFailure());
    }
  }
}
