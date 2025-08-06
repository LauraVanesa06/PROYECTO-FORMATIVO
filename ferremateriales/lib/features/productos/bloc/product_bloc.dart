import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import '../model/product_model.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<ProductEntrarPressed>((event, emit) async {
      emit(ProductLoadInProgress());

      try {
        // PETICIÓN HTTP A TU BACKEND RAILS
        final response = await http.get(
          Uri.parse('http://10.0.2.2:3000/api/v1/products'),
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
            print("ERROR: El JSON no es una lista.");
            emit(ProductLoadFailure());
          }
        } else {
          print("Error en la respuesta HTTP: ${response.statusCode}");
          emit(ProductLoadFailure());
        }
      } catch (e) {
        print("ERROR al cargar productos: $e");
        emit(ProductLoadFailure());
      }
    });

    on<ProductRegresarPressed>((event, emit) {
      emit(ProductInitial());
    });
  }
}
