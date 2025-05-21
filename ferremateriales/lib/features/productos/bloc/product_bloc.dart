import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<ProductEntrarPressed>((event, emit) async {
      final url = Uri.parse('https://run.mocky.io/v3/9c91e150-52e6-43f3-bbc1-53b65b7daae7');
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
