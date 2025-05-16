import 'package:flutter_bloc/flutter_bloc.dart';

// El Cubit que maneja el contador
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0); // Estado inicial = 0

  // Método para incrementar el contador
  void increment() => emit(state + 1);

  // Método para resetear el contador a 0
  void descrementar() => emit(state - 1); // Cambié el nombre a descrementar para que sea más claro
  void reset() => emit(0); // Resetear el contador a 0
}
