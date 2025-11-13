part of 'product_bloc.dart';

sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

// Estado inicial (sin datos cargados)
final class ProductInitial extends ProductState {}

// Estado mientras se cargan los productos (spinner, etc.)
final class ProductLoadInProgress extends ProductState {}

// Estado cuando la carga falla (permite mostrar mensaje)
final class ProductLoadFailure extends ProductState {
  final String? message;

  const ProductLoadFailure([this.message]);

  @override
  List<Object?> get props => [message];
}

// Estado cuando la carga fue exitosa
final class ProductLoadSuccess extends ProductState {
  final List<ProductModel> productos;

  const ProductLoadSuccess(this.productos);

  @override
  List<Object?> get props => [productos];
}
