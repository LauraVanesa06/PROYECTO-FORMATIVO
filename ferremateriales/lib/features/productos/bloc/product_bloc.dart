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

      final url = Uri.parse('https://run.mocky.io/v3/c09b02e5-3af7-4fed-ae15-a76377353fb1');

      try {
        final response = await http.get(url);

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