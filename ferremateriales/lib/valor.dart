import 'package:flutter_bloc/flutter_bloc.dart';
class Valor extends Cubit<double>{
  
  Valor() : super(0);
  void establecerValor(double valor) => emit(valor);

  void descuento1() => emit(state * 0.5);
  void descuento2() => emit(state * 0.25);

}