import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import '../model/product_model.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<ProductEntrarPressed>((event, emit) async {
      final url = Uri.parse('https://run.mocky.io/v3/c09b02e5-3af7-4fed-ae15-a76377353fb1');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        emit(ProductLoadSuccess());
      } else {
          emit(ProductLoadFailure());
      }
    });
    on<ProductRegresarPressed>((event, emit) async {
      emit(ProductInitial());
    });
  }
}
