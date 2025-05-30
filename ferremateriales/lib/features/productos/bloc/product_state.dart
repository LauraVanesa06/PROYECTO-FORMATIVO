part of 'product_bloc.dart';

sealed class ProductState extends Equatable {
  const ProductState();
  
  @override
  List<Object> get props => [];
}

final class ProductInitial extends ProductState {}

final class ProductLoadInProgress extends ProductState {}

final class ProductLoadFailure extends ProductState {
  get message => null;
}

final class ProductLoadSuccess extends ProductState {
  final List<ProductModel> productos;

  const ProductLoadSuccess(this.productos);

  
  @override
  List<Object> get props => [productos];
}
