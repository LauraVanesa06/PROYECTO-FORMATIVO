import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import '../model/category_model.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/api/v1/categories'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final categories =
            data.map((e) => CategoryModel.fromJson(e)).toList();
        emit(CategoryLoaded(categories));
      } else {
        emit(CategoryError('Error al cargar categorías'));
      }
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
