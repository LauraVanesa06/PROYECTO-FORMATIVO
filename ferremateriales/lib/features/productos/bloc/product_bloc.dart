import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import '../model/product_model.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<ProductEntrarPressed>(_onLoadProducts);
    on<ToggleFavorite>(_onToggleFavorite); // 👈 Agregado
  }

  Future<void> _onLoadProducts(ProductEntrarPressed event, Emitter<ProductState> emit) async {
    emit(ProductLoadInProgress());

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/v1/products'),
      );

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
      emit(ProductLoadFailure());
    }
  }

  void _onToggleFavorite(ToggleFavorite event, Emitter<ProductState> emit) {
    if (state is ProductLoadSuccess) {
      final currentState = state as ProductLoadSuccess;

      final updatedProducts = currentState.productos.map((product) {
        if (product.id == event.productId) {
          return product.copyWith(isFavorite: !product.isFavorite);
        }
        return product;
      }).toList();

      emit(ProductLoadSuccess(updatedProducts));
    }
  }
}