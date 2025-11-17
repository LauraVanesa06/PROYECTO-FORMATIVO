part of 'product_bloc.dart';

sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

final class ProductInitial extends ProductState {}

final class ProductLoadInProgress extends ProductState {}

final class ProductLoadFailure extends ProductState {
  final String? message;
  const ProductLoadFailure([this.message]);
}

final class ProductLoadSuccess extends ProductState {
  final List<ProductModel> productos;

  const ProductLoadSuccess(this.productos);

  @override
  List<Object?> get props => [
    productos.length,
    // Añade el hashCode de los IDs para forzar comparación más profunda
    productos.map((p) => p.id).join(','),
  ];
}

final class ProductDestacadosSuccess extends ProductState {
  final List<ProductModel> destacados;
  const ProductDestacadosSuccess(this.destacados);
}
