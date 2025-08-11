import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../model/product_model.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<ProductEntrarPressed>((event, emit) async {
      emit(ProductLoadInProgress());

      try {
        // Leer el archivo JSON desde assets
        final String jsonString = await rootBundle.loadString('assets/json/ferre.json');
        final decoded = jsonDecode(jsonString);

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
